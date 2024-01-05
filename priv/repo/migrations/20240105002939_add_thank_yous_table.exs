defmodule EctoSecretSanta.Repo.Migrations.AddThankYousTable do
  use Ecto.Migration

  def change do
    create table("thank_yous") do
      add :message, :string, null: false
      add :event_id, references(:events), null: false
      add :sender_id, references(:users), null: false
      add :recipient_id, references(:users), null: false

      timestamps()
    end
  end
end
