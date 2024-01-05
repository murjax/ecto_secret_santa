defmodule EctoSecretSanta.Repo.Migrations.AddInvitesTable do
  use Ecto.Migration

  def change do
    create table("invites") do
      add :name, :string, null: false
      add :email, :string, null: false
      add :status, :integer, null: false, default: 0
      add :event_id, references(:events)
      add :user_id, references(:users)

      timestamps()
    end
  end
end
