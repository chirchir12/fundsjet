defmodule FundsjetWeb.UserController do
  use FundsjetWeb, :controller

  alias Fundsjet.Identity
  alias Fundsjet.Identity.User

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    users = Identity.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"params" => user_params}) do
    with {:ok, %User{} = user} <- Identity.create_user(user_params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => uuid}) do
    with {:ok, user} <- Identity.get_user_by(:uuid, uuid) do
      conn
      |> render(:show, user: user)
    end
  end

  def update(conn, %{"id" => uuid, "params" => user_params}) do
    with {:ok, user} <- Identity.get_user_by(:uuid, uuid),
         {:ok, %User{} = user} <- Identity.update_user(user, user_params) do
      conn
      |> render(:show, user: user)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with {:ok, user} <- Identity.get_user_by(:uuid, uuid),
         {:ok, %User{}} <- Identity.delete_user(user) do
      conn
      |> send_resp(:no_content, "")
    end
  end
end
