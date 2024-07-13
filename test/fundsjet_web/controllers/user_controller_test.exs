defmodule FundsjetWeb.UserControllerTest do
  use FundsjetWeb.ConnCase

  import Fundsjet.IdentityFixtures

  alias Fundsjet.Identity.User

  @create_attrs %{
    type: "some type",
    username: "some username",
    uuid: "some uuid",
    email: "some email",
    first_name: "some first_name",
    last_name: "some last_name",
    primary_phone: "some primary_phone"
  }
  @update_attrs %{
    type: "some updated type",
    username: "some updated username",
    uuid: "some updated uuid",
    email: "some updated email",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    primary_phone: "some updated primary_phone"
  }
  @invalid_attrs %{
    type: nil,
    username: nil,
    uuid: nil,
    email: nil,
    first_name: nil,
    last_name: nil,
    primary_phone: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all identity", %{conn: conn} do
      conn = get(conn, ~p"/api/identity")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/identity", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/identity/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some email",
               "first_name" => "some first_name",
               "last_name" => "some last_name",
               "primary_phone" => "some primary_phone",
               "type" => "some type",
               "username" => "some username",
               "uuid" => "some uuid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/identity", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/identity/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/identity/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "first_name" => "some updated first_name",
               "last_name" => "some updated last_name",
               "primary_phone" => "some updated primary_phone",
               "type" => "some updated type",
               "username" => "some updated username",
               "uuid" => "some updated uuid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/identity/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/identity/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/identity/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
