defmodule FundsjetWeb.AddAuthUserPlug do
  import Phoenix.Controller
  import Plug.Conn
  alias Fundsjet.Identity.Auth.Guardian

  def init(default), do: default

  def call(conn, _) do
    case Guardian.Plug.authenticated?(conn) do
      true ->
        conn |> assign(:auth_user, Guardian.Plug.current_resource(conn))

      false ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: FundsjetWeb.ErrorJSON)
        |> render(:"401",
          error: %{
            detail: :unauthorized
          }
        )
        |> halt()
    end
  end
end
