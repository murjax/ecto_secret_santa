defmodule EctoSecretSanta.Repo.Migrations.AddWishListItemsTable do
  use Ecto.Migration

  def change do
    create table("wish_list_items") do
      add :name, :string, null: false
      add :url, :string
      add :site_image_url, :string
      add :site_description, :string
      add :event_id, references(:events), null: false
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
