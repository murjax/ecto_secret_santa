defmodule EctoSecretSanta.WishListItem do
  use Ecto.Schema

  schema "wish_list_items" do
    field :name, :string
    field :url, :string
    field :site_image_url, :string
    field :site_description, :string
    belongs_to :user, EctoSecretSanta.User
    belongs_to :event, EctoSecretSanta.Event
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end
end
