defmodule Fundsjet.Identity.Users do
  @moduledoc """
  Users module
  """

  import Ecto.Query, warn: false
  alias Fundsjet.Repo
  alias Fundsjet.Identity.User

  @doc """
  Fetches a list of all users from the database.

  ## Examples

      iex> Fundsjet.Identity.Users.list()
      [%User{id: 1, name: "Alice"}, %User{id: 2, name: "Bob"}]

  """
  def list do
    Repo.all(User)
  end

  @doc """
  Fetches a user from the database based on the provided identifier type and value.

  ## Parameters

    - `:uuid`: Fetches a user by UUID.
    - `:email`: Fetches a user by email.
    - `:id`: Fetches a user by ID.

  ## Examples

    Fetching a user by UUID:

        iex>  Fundsjet.Identity.Users.get(:uuid, "123e4567-e89b-12d3-a456-426614174000")
        {:ok, %User{}}

        iex>  Fundsjet.Identity.Users.get(:uuid, "non-existent-uuid")
        {:error, :user_not_found}

    Fetching a user by email:

        iex>  Fundsjet.Identity.Users.get(:email, "user@example.com")
        {:ok, %User{}}

        iex>  Fundsjet.Identity.Users.get(:email, "non-existent-email@example.com")
        {:error, :user_not_found}

    Fetching a user by ID:

        iex>  Fundsjet.Identity.Users.get(:id, 1)
        {:ok, %User{}}

        iex>  Fundsjet.Identity.Users.get(:id, 999)
        {:error, :user_not_found}

  ## Returns

    - `{:ok, %User{}}` if a user is found.
    - `{:error, :user_not_found}` if no user is found.
  """
  def get(:uuid, uuid) do
    case Repo.get_by(User, uuid: uuid) do
      nil ->
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  def get(:email, email) do
    case Repo.get_by(User, email: String.downcase(email)) do
      nil ->
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  def get(:username, username) do
    case Repo.get_by(User, username: String.downcase(username)) do
      nil ->
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  def get(:id, id) do
    case Repo.get(User, id) do
      nil ->
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    attrs = Map.put(attrs, "email_verified", false)
    attrs = Map.put(attrs, "is_active", true)

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%User{} = user) do
    Repo.delete(user)
  end
end
