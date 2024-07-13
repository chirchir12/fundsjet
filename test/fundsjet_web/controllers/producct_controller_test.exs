defmodule FundsjetWeb.ProducctControllerTest do
  use FundsjetWeb.ConnCase

  import Fundsjet.ProductsFixtures

  alias Fundsjet.Products.Producct

  @create_attrs %{
    code: "some code",
    name: "some name",
    status: "some status",
    currency: "some currency",
    start_date: ~D[2024-07-12],
    end_date: ~D[2024-07-12],
    is_enabled: true,
    updated_by: 42,
    created_by: 42,
    require_approval: true,
    require_docs: true
  }
  @update_attrs %{
    code: "some updated code",
    name: "some updated name",
    status: "some updated status",
    currency: "some updated currency",
    start_date: ~D[2024-07-13],
    end_date: ~D[2024-07-13],
    is_enabled: false,
    updated_by: 43,
    created_by: 43,
    require_approval: false,
    require_docs: false
  }
  @invalid_attrs %{
    code: nil,
    name: nil,
    status: nil,
    currency: nil,
    start_date: nil,
    end_date: nil,
    is_enabled: nil,
    updated_by: nil,
    created_by: nil,
    require_approval: nil,
    require_docs: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create producct" do
    test "renders producct when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", producct: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "code" => "some code",
               "created_by" => 42,
               "currency" => "some currency",
               "end_date" => "2024-07-12",
               "is_enabled" => true,
               "name" => "some name",
               "require_approval" => true,
               "require_docs" => true,
               "start_date" => "2024-07-12",
               "status" => "some status",
               "updated_by" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", producct: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update producct" do
    setup [:create_producct]

    test "renders producct when data is valid", %{
      conn: conn,
      producct: %Producct{id: id} = producct
    } do
      conn = put(conn, ~p"/api/products/#{producct}", producct: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "code" => "some updated code",
               "created_by" => 43,
               "currency" => "some updated currency",
               "end_date" => "2024-07-13",
               "is_enabled" => false,
               "name" => "some updated name",
               "require_approval" => false,
               "require_docs" => false,
               "start_date" => "2024-07-13",
               "status" => "some updated status",
               "updated_by" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, producct: producct} do
      conn = put(conn, ~p"/api/products/#{producct}", producct: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete producct" do
    setup [:create_producct]

    test "deletes chosen producct", %{conn: conn, producct: producct} do
      conn = delete(conn, ~p"/api/products/#{producct}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/products/#{producct}")
      end
    end
  end

  defp create_producct(_) do
    producct = producct_fixture()
    %{producct: producct}
  end
end
