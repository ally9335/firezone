defmodule FgHttp.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias FgHttp.Repo

  alias FgHttp.Users.User

  # one hour
  @sign_in_token_validity_secs 3600

  def consume_sign_in_token(token) when is_binary(token) do
    validity_secs = -1 * @sign_in_token_validity_secs
    now = DateTime.utc_now()

    update_fn = fn user ->
      case from(u in User, where: u.id == ^user.id)
           |> Repo.update_all(set: [sign_in_token: nil, sign_in_token_created_at: nil]) do
        {1, _result} ->
          {:ok, user}

        _ ->
          # Rollback transaction
          {:error, "Unexpected error attempting to clear sign in token."}
      end
    end

    {:ok, result} =
      Repo.transaction(fn ->
        case Repo.one(
               from(u in User,
                 where:
                   u.sign_in_token == ^token and
                     u.sign_in_token_created_at > datetime_add(^now, ^validity_secs, "second")
               )
             ) do
          nil ->
            {:error, "Token invalid."}

          user ->
            update_fn.(user)
        end
      end)

    result
  end

  def get_user!(email: email) do
    Repo.get_by!(User, email: email)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs) when is_list(attrs) do
    attrs
    |> Enum.into(%{})
    |> create_user()
  end

  def create_user(attrs) when is_map(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def single_user? do
    Repo.one(from u in User, select: count()) == 1
  end

  # For now, assume first User is admin
  def admin do
    User |> first |> Repo.one()
  end

  def admin_email do
    case admin() do
      %User{} = user ->
        user.email

      _ ->
        nil
    end
  end
end
