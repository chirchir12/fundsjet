defmodule FundsjetWeb.AuthJSON do
  alias Fundsjet.Identity.User

  def auth_user(%{user: %User{} = user, access_token: access_token, refresh_token: refresh_token}) do
    %{
      data: %{
        user: %{
          id: user.uuid,
          type: user.type,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          primary_phone: user.primary_phone
        },
        access_token: access_token,
        refresh_token: refresh_token
      }
    }
  end

  def token(%{access_token: access_token}) do
    %{
      data: %{
        access_token: access_token
      }
    }
  end
end
