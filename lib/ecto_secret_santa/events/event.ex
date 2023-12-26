defmodule EctoSecretSanta.Event do
  use Ecto.Schema

  schema "events" do
    field :name, :string
    field :date, :utc_datetime
    field :send_reminder, :boolean
    belongs_to :owner, EctoSecretSanta.User
    has_many :invites, EctoSecretSanta.Invite
    has_many :pairings, EctoSecretSanta.Pairing
    has_many :wish_list_items, EctoSecretSanta.WishListItem
    has_many :thank_yous, EctoSecretSanta.ThankYou
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end
end
