defmodule EctoSecretSanta.BasicQueries do
  import Ecto.Query
  alias EctoSecretSanta.Repo

  def basic_query do
    query = from u in "users",
    select: [u.id, u.email, u.name]
    Repo.all(query)
  end

  def query_with_join do
    # query = from u in "users",
    # join: e in "events", on: u.id == e.owner_id,
    #   where: e.id == 3,
    #   select: [u.id, u.name, u.email]

    query = "users"
            |> join(:inner, [u], e in "events", on: u.id == e.owner_id)
            |> where([_u, e], e.id == 3)
            |> select([u, e], [u.id, u.name, u.email, e.name])

    Repo.all(query)
  end

  def query_with_multiple_joins do
    query = from i in "wish_list_items",
    join: e in "events", on: e.id == i.event_id,
      join: o in "users", on: o.id == e.owner_id,
      join: u in "users", on: u.id == i.user_id,
      where: e.id == 3,
      select: [i.name, u.name, u.email, o.name, o.email, e.name]
    Repo.all(query)
  end

  def query_with_fragment do
    query = from u in "users",
    where: fragment("email LIKE '%.net'"),
      select: [u.id, u.email, u.name]
    Repo.all(query)
  end
end
