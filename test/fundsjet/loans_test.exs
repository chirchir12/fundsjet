defmodule Fundsjet.LoansTest do
  use Fundsjet.DataCase

  alias Fundsjet.Loans

  describe "loans" do
    alias Fundsjet.Loans.Loan

    import Fundsjet.LoansFixtures

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

    test "list_loans/0 returns all loans" do
      loan = loan_fixture()
      assert Loans.list_loans() == [loan]
    end

    test "get_loan!/1 returns the loan with given id" do
      loan = loan_fixture()
      assert Loans.get_loan!(loan.id) == loan
    end

    test "create_loan/1 with valid data creates a loan" do
      valid_attrs = %{
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

      assert {:ok, %Loan{} = loan} = Loans.create_loan(valid_attrs)
      assert loan.meta == %{}
      assert loan.status == "some status"
      assert loan.term == 42
      assert loan.uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert loan.customer_id == 42
      assert loan.product_id == 42
      assert loan.amount == Decimal.new("120.5")
      assert loan.commission == Decimal.new("120.5")
      assert loan.maturity_date == ~D[2024-07-14]
      assert loan.duration == 42
      assert loan.disbursed_on == ~D[2024-07-14]
      assert loan.closed_on == ~D[2024-07-14]
      assert loan.created_by == 42
      assert loan.updated_by == 42
    end

    test "create_loan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Loans.create_loan(@invalid_attrs)
    end

    test "update_loan/2 with valid data updates the loan" do
      loan = loan_fixture()

      update_attrs = %{
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

      assert {:ok, %Loan{} = loan} = Loans.update_loan(loan, update_attrs)
      assert loan.meta == %{}
      assert loan.status == "some updated status"
      assert loan.term == 43
      assert loan.uuid == "7488a646-e31f-11e4-aace-600308960668"
      assert loan.customer_id == 43
      assert loan.product_id == 43
      assert loan.amount == Decimal.new("456.7")
      assert loan.commission == Decimal.new("456.7")
      assert loan.maturity_date == ~D[2024-07-15]
      assert loan.duration == 43
      assert loan.disbursed_on == ~D[2024-07-15]
      assert loan.closed_on == ~D[2024-07-15]
      assert loan.created_by == 43
      assert loan.updated_by == 43
    end

    test "update_loan/2 with invalid data returns error changeset" do
      loan = loan_fixture()
      assert {:error, %Ecto.Changeset{}} = Loans.update_loan(loan, @invalid_attrs)
      assert loan == Loans.get_loan!(loan.id)
    end

    test "delete_loan/1 deletes the loan" do
      loan = loan_fixture()
      assert {:ok, %Loan{}} = Loans.delete_loan(loan)
      assert_raise Ecto.NoResultsError, fn -> Loans.get_loan!(loan.id) end
    end

    test "change_loan/1 returns a loan changeset" do
      loan = loan_fixture()
      assert %Ecto.Changeset{} = Loans.change_loan(loan)
    end
  end
end
