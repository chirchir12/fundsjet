defmodule FundsjetWeb.AuthController do
  use FundsjetWeb, :controller
  alias Fundsjet.Identity.Auth

  action_fallback FundsjetWeb.FallbackController

  def login(conn, %{"email" => email, "password" => plain_password}) do
    with {:ok, user, access_token, refresh_token} <- Auth.login(email, plain_password) do
      conn
      |> put_status(:ok)
      |> render(:auth_user, user: user, access_token: access_token, refresh_token: refresh_token)
    end
  end

  def register(conn, %{"user" => user_params}) do
    with {:ok, user, access_token, refresh_token} <- Auth.register(user_params) do
      conn
      |> put_status(:created)
      |> render(:auth_user, user: user, access_token: access_token, refresh_token: refresh_token)
    end
  end

  def refresh_token(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, access_token} <- Auth.renew_access(refresh_token) do
      conn
      |> put_status(:ok)
      |> render(:token, access_token: access_token)
    end
  end

  def revoke_refresh_token(conn, %{"refresh_token" => refresh_token}) do
    with :ok <- Auth.revoke_refresh_token(refresh_token) do
      send_resp(conn, :no_content, "")
    end
  end
end
