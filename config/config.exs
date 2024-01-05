import Config

config :ecto_secret_santa, EctoSecretSanta.Repo,
database: "secret_santa_development",
username: "postgres",
password: "postgres",
hostname: "localhost",
migration_timestamps: [
  type: :utc_datetime,
  inserted_at: :created_at,
  updated_at: :updated_at
]

config :ecto_secret_santa, :ecto_repos, [EctoSecretSanta.Repo]
