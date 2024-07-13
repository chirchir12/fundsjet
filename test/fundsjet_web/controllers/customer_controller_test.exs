defmodule FundsjetWeb.CustomerControllerTest do
  use FundsjetWeb.ConnCase

  import Fundsjet.CustomersFixtures

  alias Fundsjet.Customers.Customer

  @create_attrs %{
    user_id: 42,
    customer_number: "some customer_number",
    first_name: "some first_name",
    last_name: "some last_name",
    phone_number: "some phone_number",
    email: "some email",
    identification_type: "some identification_type",
    identification_number: "some identification_number",
    profile_pic: "some profile_pic"
  }
  @update_attrs %{
    user_id: 43,
    customer_number: "some updated customer_number",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    phone_number: "some updated phone_number",
    email: "some updated email",
    identification_type: "some updated identification_type",
    identification_number: "some updated identification_number",
    profile_pic: "some updated profile_pic"
  }
  @invalid_attrs %{
    user_id: nil,
    customer_number: nil,
    first_name: nil,
    last_name: nil,
    phone_number: nil,
    email: nil,
    identification_type: nil,
    identification_number: nil,
    profile_pic: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all customers", %{conn: conn} do
      conn = get(conn, ~p"/api/customers")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create customer" do
    test "renders customer when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/customers", customer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/customers/#{id}")

      assert %{
               "id" => ^id,
               "customer_number" => "some customer_number",
               "email" => "some email",
               "first_name" => "some first_name",
               "identification_number" => "some identification_number",
               "identification_type" => "some identification_type",
               "last_name" => "some last_name",
               "phone_number" => "some phone_number",
               "profile_pic" => "some profile_pic",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/customers", customer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update customer" do
    setup [:create_customer]

    test "renders customer when data is valid", %{
      conn: conn,
      customer: %Customer{id: id} = customer
    } do
      conn = put(conn, ~p"/api/customers/#{customer}", customer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/customers/#{id}")

      assert %{
               "id" => ^id,
               "customer_number" => "some updated customer_number",
               "email" => "some updated email",
               "first_name" => "some updated first_name",
               "identification_number" => "some updated identification_number",
               "identification_type" => "some updated identification_type",
               "last_name" => "some updated last_name",
               "phone_number" => "some updated phone_number",
               "profile_pic" => "some updated profile_pic",
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, customer: customer} do
      conn = put(conn, ~p"/api/customers/#{customer}", customer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete customer" do
    setup [:create_customer]

    test "deletes chosen customer", %{conn: conn, customer: customer} do
      conn = delete(conn, ~p"/api/customers/#{customer}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/customers/#{customer}")
      end
    end
  end

  defp create_customer(_) do
    customer = customer_fixture()
    %{customer: customer}
  end
end
