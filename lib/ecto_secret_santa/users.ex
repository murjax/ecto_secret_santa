defmodule EctoSecretSanta.Users do
  import Ecto.Query, warn: false

  alias EctoSecretSanta.Repo
  alias EctoSecretSanta.User

  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  def list_users do
    Repo.all(User)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    user
    |> Repo.delete()
  end
end
