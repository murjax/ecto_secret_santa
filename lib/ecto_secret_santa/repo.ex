defmodule EctoSecretSanta.Repo do
  use Ecto.Repo,
    otp_app: :ecto_secret_santa,
    adapter: Ecto.Adapters.Postgres
end
