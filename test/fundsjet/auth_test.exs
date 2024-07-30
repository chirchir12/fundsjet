defmodule Fundsjet.Identity.AuthTest do
  use Fundsjet.DataCase
  alias Ecto.Changeset

  describe "Auth" do
    setup :create_user
    alias Fundsjet.Identity.{Auth, Auth.Guardian, User}

    test "login/2 authenticate with correct credentials ", %{user: user} do
      assert {:ok, {%User{} = logged_in_user, access, refresh}} =
               Auth.login("test@mail.com", "password")

      assert logged_in_user == user
      assert {:ok, _claim} = Guardian.decode_and_verify(access, %{"typ" => "access"})
      assert {:ok, _claim} = Guardian.decode_and_verify(refresh, %{"typ" => "refresh"})
    end

    test "login/2 return error changeset when email is not valid" do
      assert {:error, %Changeset{}} = Auth.login("testmail.com", "password")
    end

    test "login/2 return error  when password is wrong" do
      assert {:error, :invalid_password} = Auth.login("test@mail.com", "paas")
    end

    test "login/2 return error  when user with this email is not found" do
      assert {:error, :user_not_found} = Auth.login("no@mail.com", "password")
    end

    test "renew_access/1 return new access token given valid refresh token" do
      assert {:ok, {%User{} = _logged_in_user, access, refresh}} =
               Auth.login("test@mail.com", "password")

      assert {:ok, new_access} = Auth.renew_access(refresh)
      assert new_access != access
      assert {:ok, _claim} = Guardian.decode_and_verify(new_access, %{"typ" => "access"})
    end

    test "renew_access/1 return error when refresh token is not valid" do
      assert {:error, :invalid_token} = Auth.renew_access("refresh")
    end

    test "revoke_refresh_token/1 revokes valid refresh token" do
      assert {:ok, {%User{} = _logged_in_user, _access, refresh}} =
               Auth.login("test@mail.com", "password")

      assert :ok = Auth.revoke_refresh_token(refresh)

      assert {:error, :token_not_found} = Auth.renew_access(refresh)
    end
  end

  defp create_user(_) do
    user =
      Fundsjet.Identity.UsersFixtures.create_user_fixture(%{
        "email" => "test@mail.com",
        "password" => "password"
      })

    %{user: user}
  end
end
