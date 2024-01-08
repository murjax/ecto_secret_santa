# Query Objectives:
# --- INSERTIONS ---
# 1. Create a user
# 2. Create an event with the user as an owner
# 3. Create another event along with a new event owner
# 4. Create an event with 10 invites (6 accepted, 4 declined)
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
# 2. Delete events with no invites

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

  # --- DELETIONS ---
  # 1. Delete a user
  {:ok, user} = (
    %User{name: Faker.Person.name(), email: Faker.Internet.email()}
    |> Repo.insert
  )
  Repo.delete(user)

  # 2. Delete events with no invites
  query = from e in Event,
  left_join: i in Invite, on: i.event_id == e.id,
  where: is_nil(i.id),
  distinct: true

  events = Repo.all(query)
  event_ids = Enum.map(events, fn event -> event.id end)
  query = from e in Event, where: e.id in ^event_ids
  Repo.delete_all(query)
