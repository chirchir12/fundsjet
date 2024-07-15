defmodule FundsjetWeb.LoanControllerTest do
  use FundsjetWeb.ConnCase

  import Fundsjet.LoansFixtures

  alias Fundsjet.Loans.Loan

  @create_attrs %{
    meta: %{},
    status: "some status",
    term: 42,
    uuid: "7488a646-e31f-11e4-aace-600308960662",
    customer_id: 42,
    product_id: 42,
    amount: "120.5",
    commission: "120.5",
    maturity_date: ~D[2024-07-14],
    duration: 42,
    disbursed_on: ~D[2024-07-14],
    closed_on: ~D[2024-07-14],
    created_by: 42,
    updated_by: 42
  }
  @update_attrs %{
    meta: %{},
    status: "some updated status",
    term: 43,
    uuid: "7488a646-e31f-11e4-aace-600308960668",
    customer_id: 43,
    product_id: 43,
    amount: "456.7",
    commission: "456.7",
    maturity_date: ~D[2024-07-15],
    duration: 43,
    disbursed_on: ~D[2024-07-15],
    closed_on: ~D[2024-07-15],
    created_by: 43,
    updated_by: 43
  }
  @invalid_attrs %{
    meta: nil,
    status: nil,
    term: nil,
    uuid: nil,
    customer_id: nil,
    product_id: nil,
    amount: nil,
    commission: nil,
    maturity_date: nil,
    duration: nil,
    disbursed_on: nil,
    closed_on: nil,
    created_by: nil,
    updated_by: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all loans", %{conn: conn} do
      conn = get(conn, ~p"/api/loans")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create loan" do
    test "renders loan when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/loans", loan: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/loans/#{id}")

      assert %{
               "id" => ^id,
               "amount" => "120.5",
               "closed_on" => "2024-07-14",
               "commission" => "120.5",
               "created_by" => 42,
               "customer_id" => 42,
               "disbursed_on" => "2024-07-14",
               "duration" => 42,
               "maturity_date" => "2024-07-14",
               "meta" => %{},
               "product_id" => 42,
               "status" => "some status",
               "term" => 42,
               "updated_by" => 42,
               "uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/loans", loan: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update loan" do
    setup [:create_loan]

    test "renders loan when data is valid", %{conn: conn, loan: %Loan{id: id} = loan} do
      conn = put(conn, ~p"/api/loans/#{loan}", loan: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/loans/#{id}")

      assert %{
               "id" => ^id,
               "amount" => "456.7",
               "closed_on" => "2024-07-15",
               "commission" => "456.7",
               "created_by" => 43,
               "customer_id" => 43,
               "disbursed_on" => "2024-07-15",
               "duration" => 43,
               "maturity_date" => "2024-07-15",
               "meta" => %{},
               "product_id" => 43,
               "status" => "some updated status",
               "term" => 43,
               "updated_by" => 43,
               "uuid" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, loan: loan} do
      conn = put(conn, ~p"/api/loans/#{loan}", loan: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete loan" do
    setup [:create_loan]

    test "deletes chosen loan", %{conn: conn, loan: loan} do
      conn = delete(conn, ~p"/api/loans/#{loan}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/loans/#{loan}")
      end
    end
  end

  defp create_loan(_) do
    loan = loan_fixture()
    %{loan: loan}
  end
end
