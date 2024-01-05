defmodule EctoSecretSanta.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :name, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string
      add :avatar_url, :string

      timestamps()
    end
  end
end
