defmodule FundsjetWeb.UserController do
  use FundsjetWeb, :controller

  alias Fundsjet.Identity.{User, Users}

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    users = Users.list()
    render(conn, :index, users: users)
  end

  def create(conn, %{"params" => params}) do
    with {:ok, %User{} = user} <- Users.create(params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => uuid}) do
    with {:ok, user} <- Users.get(:uuid, uuid) do
      conn
      |> render(:show, user: user)
    end
  end

  def update(conn, %{"id" => uuid, "params" => params}) do
    with {:ok, user} <- Users.get(:uuid, uuid),
         {:ok, %User{} = user} <- Users.update(user, params) do
      conn
      |> render(:show, user: user)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with {:ok, user} <- Users.get(:uuid, uuid),
         {:ok, %User{}} <- Users.delete(user) do
      conn
      |> send_resp(:no_content, "")
    end
  end
end
