defmodule Fundsjet.IdentityTest do
  use Fundsjet.DataCase

  alias Fundsjet.Identity

  describe "identity" do
    alias Fundsjet.Identity.User

    import Fundsjet.IdentityFixtures

    @invalid_attrs %{
      type: nil,
      username: nil,
      uuid: nil,
      email: nil,
      first_name: nil,
      last_name: nil,
      primary_phone: nil
    }

    test "list_identity/0 returns all identity" do
      user = user_fixture()
      assert Identity.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Identity.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        email: "email@email.com",
        first_name: "first_name",
        last_name: "last_name",
        primary_phone: "000000",
        type: "staff",
        username: "username",
        password: "password"
      }

      assert {:ok, %User{} = user} = Identity.create_user(valid_attrs)
      assert user.type == "staff"
      assert user.username == "username"
      assert user.uuid != nil
      assert user.email == "email@email.com"
      assert user.first_name == "first_name"
      assert user.last_name == "last_name"
      assert user.primary_phone == "000000"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        type: "some updated type",
        username: "some updated username",
        uuid: "some updated uuid",
        email: "some updated email",
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        primary_phone: "some updated primary_phone"
      }

      assert {:ok, %User{} = user} = Identity.update_user(user, update_attrs)
      assert user.type == "some updated type"
      assert user.username == "some updated username"
      assert user.uuid == "some updated uuid"
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.primary_phone == "some updated primary_phone"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Identity.update_user(user, @invalid_attrs)
      assert user == Identity.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Identity.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Identity.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Identity.change_user(user)
    end
  end
end
