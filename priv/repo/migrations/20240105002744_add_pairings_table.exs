defmodule EctoSecretSanta.Repo.Migrations.AddPairingsTable do
  use Ecto.Migration

  def change do
    create table("pairings") do
      add :event_id, references(:events), null: false
      add :santa_id, references(:users), null: false
      add :person_id, references(:users), null: false

      timestamps()
    end
  end
end
