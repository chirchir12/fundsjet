defmodule FundsjetWeb.UserJSON do
  alias Fundsjet.Identity.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      uuid: user.uuid,
      username: user.username,
      email: user.email,
      type: user.type,
      first_name: user.first_name,
      last_name: user.last_name,
      primary_phone: user.primary_phone
    }
  end
end
