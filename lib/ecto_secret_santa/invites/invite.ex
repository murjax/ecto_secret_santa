defmodule EctoSecretSanta.Invite do
  use Ecto.Schema

  schema "invites" do
    field :name, :string
    field :email, :string
    field :status, Ecto.Enum, values: [invited: 0, accepted: 1, declined: 2]
    belongs_to :user, EctoSecretSanta.User
    belongs_to :event, EctoSecretSanta.Event
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end
end
