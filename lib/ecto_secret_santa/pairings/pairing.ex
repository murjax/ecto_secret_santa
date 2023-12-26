defmodule EctoSecretSanta.Pairing do
  use Ecto.Schema

  schema "pairings" do
    belongs_to :santa, EctoSecretSanta.User
    belongs_to :person, EctoSecretSanta.User
    belongs_to :event, EctoSecretSanta.Event
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end
end
