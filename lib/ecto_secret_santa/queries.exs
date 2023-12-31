# Query Objectives:
# --- INSERTIONS ---
# 1. Create a user
# 2. Create an event with the user as an owner
# 3. Create another event along with a new event owner
# 4. Create an event with 10 invites (6 accepted, 4 declined)
# 5. Create pairings on an event with accepted invites
# 6. Create wish list items for each event participant
# --- QUERIES ---
# 1. Select a user
# 2. Select all users
# 3. Select users with emails ending in .test
# 4. Select events belonging to a specific owner
# 5. Select past events
# 6. Select events with their owners
# 7. Select invites requested by a specific owner
# 8. Select unpaired invites
# --- UPDATES ---
# 1. Update an event date
# 2. Set a new owner on an event
# 3. Update event wish list item descriptions
# 4. Regenerate the pairings
# --- DELETIONS ---
# 1. Delete a user
# 2. Delete a user not referenced on other records
# 3. Delete a user referenced on other records
# 4. Delete past events
# 5. Delete events with no accepted invites
# --- TRANSACTIONS ---
# 1. Create an event, invites, and pairings.
# 2. Create pairings on set of events. Rollback if no accepted invites exist on an event.

defmodule EctoSecretSanta.Queries do
  import Ecto.Query
  alias Ecto.Multi
  alias EctoSecretSanta.Repo
  alias EctoSecretSanta.User
  alias EctoSecretSanta.Event
  alias EctoSecretSanta.Invite
  alias EctoSecretSanta.Pairing
  alias EctoSecretSanta.WishListItem

  # --- INSERTIONS ---
  # 1. Create a user
  {:ok, user} = (
    %User{name: Faker.Person.name(), email: Faker.Internet.email()}
    |> Repo.insert
  )

  # 2. Create an event with the user as an owner
  {:ok, event} = (
    %Event{
      name: Faker.StarWars.planet(),
      date: DateTime.utc_now |> DateTime.add(2, :day) |> DateTime.truncate(:second),
      owner: user
    }
    |> Repo.insert
  )

  # 3. Create another event along with a new event owner
  {:ok, event} = (
    %Event{
      name: Faker.StarWars.planet(),
      date: DateTime.utc_now |> DateTime.add(2, :day) |> DateTime.truncate(:second),
      owner: %User{
        name: Faker.Person.name(),
        email: Faker.Internet.email()
      }
    }
    |> Repo.insert
  )

  # 4. Create an event with 10 invites (6 accepted, 4 declined)
  {:ok, event} = (
    %Event{
      name: Faker.StarWars.planet(),
      date: DateTime.utc_now |> DateTime.add(2, :day) |> DateTime.truncate(:second),
      owner: user,
      invites: (
        Enum.map(1..6, fn _i ->
          name = Faker.Person.name()
          email = Faker.Internet.email()
          %Invite{
            name: name,
            email: email,
            status: :accepted,
            user: %User{
              name: name,
              email: email
            }
          }
        end)
        |> Enum.concat(Enum.map(1..4, fn _i ->
          name = Faker.Person.name()
          email = Faker.Internet.email()
          %Invite{
            name: name,
            email: email,
            status: :declined,
            user: %User{
              name: name,
              email: email
            }
          }
        end))
      )
    }
    |> Repo.insert
  )

  # 5. Create pairings on an event with accepted invites
  # Using Repo.insert_all
  pairing_data = (
    event.invites
    |> Enum.filter(fn invite -> invite.status == :accepted end)
    |> Enum.shuffle
    |> Enum.chunk_every(2)
    |> Enum.map(fn [santa, person] ->
      [
        santa_id: santa.user.id,
        person_id: person.user.id,
        event_id: event.id,
        created_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
      ]
    end)
  )
  Repo.insert_all("pairings", pairing_data)

  # Using Ecto.Changeset.put_assoc
  event = event |> Repo.preload(:pairings)
  pairing_structs = (
    event.invites
    |> Enum.filter(fn invite -> invite.status == :accepted end)
    |> Enum.shuffle
    |> Enum.chunk_every(2)
    |> Enum.map(fn [santa, person] ->
      %Pairing{
        santa: santa.user,
        person: person.user
      }
    end)
  )
  {:ok, event} = (
    Ecto.Changeset.change(event)
    |> Ecto.Changeset.put_assoc(:pairings, pairing_structs)
    |> Repo.update
  )

  # 6. Create wish list items for each event participant
  event = event |> Repo.preload(:wish_list_items)
  wish_list_item_structs = Enum.flat_map(event.pairings, fn pairing ->
    Enum.map(1..3, fn _i ->
      %WishListItem{
        user: pairing.person,
        name: Faker.Food.dish()
      }
    end)
  end)
  {:ok, event} = (
    Ecto.Changeset.change(event)
    |> Ecto.Changeset.put_assoc(:wish_list_items, wish_list_item_structs)
    |> Repo.update
  )

  # --- QUERIES ---
  # 1. Select a user
  Repo.get!(User, 1)

  # 2. Select all users
  Repo.all(User)

  # 3. Select users with emails ending in .test
  query = from User, where: fragment("email LIKE '%.test%'")
  Repo.all(query)

  # 4. Select events belonging to a specific owner
  query = from e in Event, where: e.owner_id == ^user.id
  Repo.all(query)

  # 5. Select past events
  query = from Event, where: fragment("date < ?", ^DateTime.utc_now())
  Repo.all(query)

  # 7. Select invites requested by a specific owner
  query = from i in Invite,
  join: e in Event, on: i.event_id == e.id,
  where: e.owner_id == ^user.id
  Repo.all(query)

  # 8. Select unpaired invites
  query = from i in Invite,
  left_join: sp in "pairings", on: i.user_id == sp.santa_id,
  left_join: pp in "pairings", on: i.user_id == pp.person_id,
  where: is_nil(sp.santa_id) and is_nil(pp.person_id) and not is_nil(i.user_id),
  distinct: true

  Repo.all(query)

  # --- UPDATES ---
  # 1. Update an event date
  event
  |> Ecto.Changeset.cast(%{date: DateTime.utc_now |> DateTime.add(7, :day) |> DateTime.truncate(:second)}, [:date])
  |> Repo.update

  # 2. Set a new owner on an event
  event
  |> Ecto.Changeset.cast(%{owner_id: user.id}, [:owner_id])
  |> Repo.update

  # 3. Update event wish list item descriptions
  # Note: Individual item gets its own description, not updating all to the same value.
  # Repo.update_all can be used with a query when updating collection to the same value is desired.
  Enum.each(event.wish_list_items, fn wish_list_item ->
    Ecto.Changeset.cast(wish_list_item, %{site_description: Faker.Lorem.word()}, [:site_description])
    |> Repo.update
  end)

  # 4. Regenerate the pairings
  from(p in Pairing, where: p.event_id == ^event.id) |> Repo.delete_all

  event = Repo.get!(Event, event.id) |> Repo.preload(invites: :user) |> Repo.preload(:pairings)
  pairing_structs = (
    event.invites
    |> Enum.filter(fn invite -> invite.status == :accepted end)
    |> Enum.shuffle
    |> Enum.chunk_every(2)
    |> Enum.map(fn [santa, person] ->
      %Pairing{
        santa: santa.user,
        person: person.user
      }
    end)
  )
  {:ok, event} = (
    Ecto.Changeset.change(event)
    |> Ecto.Changeset.put_assoc(:pairings, pairing_structs)
    |> Repo.update
  )

  # --- DELETIONS ---
  # 1. Delete a user
  Repo.delete(user)

  # 2. Delete a user not referenced on other records
  {:ok, user} = (
    %User{name: Faker.Person.name(), email: Faker.Internet.email()}
    |> Repo.insert
  )
  Repo.delete(user)

  # 3. Delete a user referenced on other records
  {:ok, user} = (
    %User{name: Faker.Person.name(), email: Faker.Internet.email()}
    |> Repo.insert
  )
  {:ok, event} = (
    %Event{
      name: Faker.StarWars.planet(),
      date: DateTime.utc_now |> DateTime.add(2, :day) |> DateTime.truncate(:second),
      owner: user
    }
    |> Repo.insert
  )
  Repo.delete(user)

  # 4. Delete past events
  query = from Event, where: fragment("date < ?", ^DateTime.utc_now())
  Repo.delete_all(query)

  # 5. Delete events with no accepted invites
  query = from e in Event,
  left_join: i in Invite, on: i.event_id == e.id,
  where: is_nil(i.id) or i.status == ^0,
  distinct: true
  Repo.all(query)

  # --- TRANSACTIONS ---
  # 1. Create an event, invites, and pairings.
  create_event_and_invites = fn repo, _ ->
    %Event{
      name: Faker.StarWars.planet(),
      date: DateTime.utc_now |> DateTime.add(2, :day) |> DateTime.truncate(:second),
      owner: user,
      invites: (
        Enum.map(1..6, fn _i ->
          name = Faker.Person.name()
          email = Faker.Internet.email()
          %Invite{
            name: name,
            email: email,
            status: :accepted,
            user: %User{
              name: name,
              email: email
            }
          }
        end)
        |> Enum.concat(Enum.map(1..4, fn _i ->
          name = Faker.Person.name()
          email = Faker.Internet.email()
          %Invite{
            name: name,
            email: email,
            status: :declined,
            user: %User{
              name: name,
              email: email
            }
          }
        end))
      )
    }
    |> repo.insert
  end
  create_pairings = fn repo, %{create_event_and_invites: event} ->
    event = event |> repo.preload(:pairings)
    pairing_structs = (
      event.invites
      |> Enum.filter(fn invite -> invite.status == :accepted end)
      |> Enum.shuffle
      |> Enum.chunk_every(2)
      |> Enum.map(fn [santa, person] ->
        %Pairing{
          santa: santa.user,
          person: person.user
        }
      end)
    )
    Ecto.Changeset.change(event)
    |> Ecto.Changeset.put_assoc(:pairings, pairing_structs)
    |> repo.update
  end

  multi = (
    Multi.new()
    |> Multi.run(:create_event_and_invites, create_event_and_invites)
    |> Multi.run(:create_pairings, create_pairings)
  )

  result = Repo.transaction(multi)

  # 2. Create pairings on set of events. Rollback if no accepted invites exist on an event.
  get_events = fn repo, _ ->
    query = from e in Event, left_join: p in Pairing, on: p.event_id == e.id, where: is_nil(p.id)
    {:ok, repo.all(query)}
  end

  create_pairings = fn repo, %{get_events: events} ->
    try do
      result = Enum.map(events, fn event ->
        event = event |> repo.preload(invites: :user) |> repo.preload(:pairings)

        has_accepted_invites = Enum.any?(event.invites, fn invite -> invite.status == :accepted end)
        if !has_accepted_invites do
          throw(:no_invites_accepted)
        end

        pairing_structs = (
          event.invites
          |> Enum.filter(fn invite -> invite.status == :accepted end)
          |> Enum.shuffle
          |> Enum.chunk_every(2)
          |> Enum.map(fn [santa, person] ->
            IO.inspect(santa.user)
            %Pairing{
              santa: santa.user,
              person: person.user
            }
          end)
        )
        Ecto.Changeset.change(event)
        |> Ecto.Changeset.put_assoc(:pairings, pairing_structs)
        |> repo.update
      end)
      {:ok, result}
    catch
      :no_invites_accepted -> {:error, "No Invites Accepted"}
    end
  end

  multi = (
    Multi.new()
    |> Multi.run(:get_events, get_events)
    |> Multi.run(:create_pairings, create_pairings)
  )

  result = Repo.transaction(multi)
end
