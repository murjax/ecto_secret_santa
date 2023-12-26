import Config

config :ecto_secret_santa, EctoSecretSanta.Repo,
database: "secret_santa_development",
username: "postgres",
password: "postgres",
hostname: "localhost"

config :ecto_secret_santa, :ecto_repos, [EctoSecretSanta.Repo]
