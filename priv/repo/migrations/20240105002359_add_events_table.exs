defmodule EctoSecretSanta.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table("events") do
      add :name, :string, null: false
      add :date, :utc_datetime, null: false
      add :send_reminder, :boolean, null: false, default: false
      add :owner_id, references(:users)

      timestamps()
    end
  end
end
