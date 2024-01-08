# Custom
defp validate_email_format(changeset) do
  domains = ~w(gmail.com yahoo.com outlook.com)

  validate_change(changeset, :email, fn field, value ->
    case Enum.any?(domains, fn domain -> String.contains?(value, domain) end) do
      true ->
        []

      false ->
        [{field, "email domain is invalid"}]
    end
  end)
end

# Ecto.Changeset.validate_format
defmodule EctoSecretSanta.User do
  @valid_domains_regex ~r/(gmail\.com|yahoo\.com|outlook\.com)/i

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :email, :hashed_password, :avatar_url])
    |> validate_required([:name, :email])
    |> validate_format(:email, @valid_domains_regex)
  end
end
