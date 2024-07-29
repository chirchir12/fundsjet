defmodule Fundsjet.Identity.UsersTest do
  use Fundsjet.DataCase

  alias Fundsjet.Identity.Users

  describe "users" do
    alias Fundsjet.Identity.User

    import Fundsjet.Identity.UsersFixtures

    @invalid_attrs %{
      "type" => nil,
      "username" => nil,
      "uuid" => nil,
      "email" => nil,
      "first_name" => nil,
      "last_name" => nil,
      "primary_phone" => nil
    }

    test "list/0 returns all users" do
      user = create_user_fixture()
      assert Users.list() == [user]
    end

    test "get/2 returns the user with given id" do
      created_user = create_user_fixture()
      assert {:ok, %User{} = user} = Users.get(:id, created_user.id)
      assert user == created_user
    end

    test "get/2 returns error when user is not found with given id" do
      assert {:error, :user_not_found} = Users.get(:id, 999)
    end

    test "get/2 returns the user with given uuid" do
      created_user = create_user_fixture()
      assert {:ok, %User{} = user} = Users.get(:uuid, created_user.uuid)
      assert user == created_user
    end

    test "get/2 returns error when user is not found with given uuid" do
      assert {:error, :user_not_found} = Users.get(:uuid, Ecto.UUID.generate())
    end

    test "get/2 returns the user with given email" do
      created_user = create_user_fixture()
      assert {:ok, %User{} = user} = Users.get(:email, created_user.email)
      assert user == created_user
    end

    test "get/2 returns error when user is not found with given email" do
      assert {:error, :user_not_found} = Users.get(:email, "noemail@mail.com")
    end

    test "get/2 returns the user with given username" do
      created_user = create_user_fixture()
      assert {:ok, %User{} = user} = Users.get(:username, created_user.username)
      assert user == created_user
    end

    test "get/2 returns error when user is not found with given username" do
      assert {:error, :user_not_found} = Users.get(:username, "username")
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        "email" => "email@email.com",
        "first_name" => "first_name",
        "last_name" => "last_name",
        "primary_phone" => "000000",
        "type" => "staff",
        "username" => "username",
        "password" => "password"
      }

      assert {:ok, %User{} = user} = Users.create(valid_attrs)
      assert user.type == "staff"
      assert user.username == "username"
      assert user.uuid != nil
      assert user.password_hash != nil
      assert user.email == "email@email.com"
      assert user.first_name == "first_name"
      assert user.last_name == "last_name"
      assert user.primary_phone == "000000"

      assert true == Argon2.verify_pass(valid_attrs["password"], user.password_hash)
    end

    test "create_user/1 with existing username return error" do
      created_user = create_user_fixture()

      valid_attrs = %{
        "email" => "email@email.com",
        "first_name" => "first_name",
        "last_name" => "last_name",
        "primary_phone" => "000000",
        "type" => "staff",
        "username" => "username",
        "password" => "password"
      }

      assert {:error, %Ecto.Changeset{}} = Users.create(valid_attrs)
    end

    test "create_user/1 with existing email return error" do
      created_user = create_user_fixture()

      valid_attrs = %{
        "email" => "email@email.com",
        "first_name" => "first_name",
        "last_name" => "last_name",
        "primary_phone" => "000000",
        "type" => "staff",
        "username" => "username1",
        "password" => "password"
      }

      assert {:error, %Ecto.Changeset{}} = Users.create(valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      created_user = create_user_fixture()

      update_attrs = %{
        type: "admin",
        username: "username1",
        first_name: "updated_first_name",
        last_name: "updated_last_name",
        primary_phone: "111111111"
      }

      assert {:ok, %User{} = user} = Users.update(created_user, update_attrs)
      assert user.type == "admin"
      assert user.username == "username1"
      assert user.uuid == created_user.uuid
      assert user.email == created_user.email
      assert user.first_name == "updated_first_name"
      assert user.last_name == "updated_last_name"
      assert user.primary_phone == "111111111"
    end

    test "update_user/2 with existing username throws error" do
      created_user1 =
        create_user_fixture(%{"username" => "username1", "email" => "email1@mail.com"})

      created_user = create_user_fixture()

      update_attrs = %{
        username: "username1"
      }

      assert {:error, %Ecto.Changeset{} = changset} = Users.update(created_user, update_attrs)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = create_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update(user, @invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = create_user_fixture()
      assert {:ok, %User{}} = Users.delete(user)
      assert {:error, :user_not_found} = Users.get(:id, user.id)
    end
  end
end
