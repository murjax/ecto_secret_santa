defmodule EctoSecretSanta.ThankYou do
  use Ecto.Schema

  schema "thank_yous" do
    field :message, :string
    belongs_to :sender, EctoSecretSanta.User
    belongs_to :recipient, EctoSecretSanta.User
    belongs_to :event, EctoSecretSanta.Event
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end
end
