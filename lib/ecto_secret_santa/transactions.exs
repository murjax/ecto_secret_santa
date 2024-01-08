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
