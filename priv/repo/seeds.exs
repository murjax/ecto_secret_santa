defmodule EctoSecretSanta.Seeder do
  alias EctoSecretSanta.Repo
  alias EctoSecretSanta.User
  alias EctoSecretSanta.Event
  alias EctoSecretSanta.Invite
  alias EctoSecretSanta.Pairing
  alias EctoSecretSanta.WishListItem
  alias EctoSecretSanta.ThankYou

  def seed do
    count = Enum.random(2..10)
    %User{
      name: Faker.Person.name(),
      email: Faker.Internet.email(),
      events: Enum.map(1..count, fn _i -> build_event() end)
    } |> Repo.insert

    Repo.all(Event)
    |> Repo.preload(invites: :user)
    |> Repo.preload(:pairings)
    |> Repo.preload(:wish_list_items)
    |> Repo.preload(:thank_yous)
    |> Enum.each(fn event ->
      pairings = event.invites |> Enum.filter(fn invite -> invite.status == :accepted end) |> build_pairings
      Ecto.Changeset.change(event)
      |> Ecto.Changeset.put_assoc(:pairings, pairings)
      |> Ecto.Changeset.put_assoc(:wish_list_items, build_wish_list_items(pairings))
      |> Ecto.Changeset.put_assoc(:thank_yous, build_thank_yous(pairings))
      |> Repo.update
    end)
  end

  def build_event do
    %Event{
      name: Faker.Lorem.word() |> String.capitalize,
      date: DateTime.utc_now |> DateTime.add(-10, :day) |> DateTime.truncate(:second),
      send_reminder: true,
      invites: build_invites()
    }
  end

  def build_invites do
    Enum.map(1..4, fn _i -> build_invite(:accepted) end)
    |> Enum.concat(Enum.map(1..2, fn _i -> build_invite(:invited) end))
    |> Enum.concat(Enum.map(1..2, fn _i -> build_invite(:declined) end))
  end

  def build_invite(status) do
    name = Faker.Person.name()
    email = Faker.Internet.email()
    %Invite{
      name: name,
      email: email,
      status: status,
      user: %User{
        name: name,
        email: email
      }
    }
  end

  def build_pairings(invites) do
    invites
    |> Enum.shuffle
    |> Enum.chunk_every(2)
    |> Enum.map(fn invite_group -> build_pairing(invite_group) end)
  end

  def build_pairing([santa, person]) do
    %Pairing{
      santa: santa.user,
      person: person.user
    }
  end

  def build_wish_list_items(pairings) do
    Enum.flat_map(pairings, fn pairing ->
      Enum.map(1..3, fn _i -> build_wish_list_item(pairing) end)
    end)
  end

  def build_wish_list_item(pairing) do
    %WishListItem{
      user: pairing.person,
      name: Faker.Food.dish()
    }
  end

  def build_thank_yous(pairings) do
    Enum.flat_map(pairings, fn pairing ->
      Enum.map(1..3, fn _i -> build_thank_you(pairing) end)
    end)
  end

  def build_thank_you(pairing) do
    %ThankYou{
      sender: pairing.person,
      recipient: pairing.santa,
      message: Faker.Lorem.sentence()
    }
  end
end

EctoSecretSanta.Seeder.seed()


# Repo.insert(
#   %User{
#     name: "John Smith",
#     email: "johnsmith@example.com",
#     events: [
#       %Event{
#         name: "Event One",
#         date: ~U[2023-12-28 14:44:52Z],
#         send_reminder: true,
#         invites: [
#           %Invite{
#             name: "Invite One",
#             email: "invite1@example.com",
#             status: :invited,
#             user: %User{
#               name: "Invite One",
#               email: "invite1@example.com"
#             }
#           },
#           %Invite{
#             name: "Invite Two",
#             email: "invite2@example.com",
#             status: :accepted,
#             user: %User{
#               name: "Invite Two",
#               email: "invite2@example.com"
#             }
#           }
#         ]
#       },
#       %Event{
#         name: "Event Two",
#         date: ~U[2023-12-29 14:44:52Z],
#         send_reminder: false
#       }
#     ]
#   }
# )
