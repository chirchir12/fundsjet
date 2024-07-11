defmodule FundsjetWeb.UserController do
  use FundsjetWeb, :controller

  alias Fundsjet.Identity
  alias Fundsjet.Identity.User

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    users = Identity.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Identity.create_user(user_params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Identity.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Identity.get_user!(id)

    with {:ok, %User{} = user} <- Identity.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Identity.get_user!(id)

    with {:ok, %User{}} <- Identity.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
