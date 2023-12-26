defmodule EctoSecretSanta.User do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :hashed_password, :string
    field :avatar_url, :string
    has_many :events, EctoSecretSanta.Event, foreign_key: :owner_id
    has_many :invites, EctoSecretSanta.Invite
    has_many :wish_list_items, EctoSecretSanta.WishListItem
    has_many :santa_pairings, EctoSecretSanta.Pairing, foreign_key: :santa_id
    has_many :person_pairings, EctoSecretSanta.Pairing, foreign_key: :person_id
    has_many :sender_thank_yous, EctoSecretSanta.ThankYou, foreign_key: :sender_id
    has_many :recipient_thank_yous, EctoSecretSanta.ThankYou, foreign_key: :recipient_id
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end
end
