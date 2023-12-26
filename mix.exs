defmodule EctoSecretSanta.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_secret_santa,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EctoSecretSanta.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.11.1"},
      {:postgrex, "~> 0.17.4"},
      {:faker, "~> 0.17.0"},
    ]
  end
end
