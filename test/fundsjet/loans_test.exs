defmodule Fundsjet.LoansTest do
  alias Fundsjet.Products
  alias Fundsjet.Loans.FilterLoan
  alias Fundsjet.Products.Product
  use Fundsjet.DataCase

  alias Fundsjet.Loans
  alias Fundsjet.Loans.Loan

  alias Fundsjet.Repo

  import Fundsjet.LoansFixtures

  describe "loans" do
    setup [:create_product, :create_customer, :create_config]

    @invalid_attrs %{
      customer_id: nil,
      amount: nil,
      created_by: nil
    }

    test "list/0 return list of loans", %{product: product, customer: customer} do
      assert Loans.list() == []

      loan = loan_fixture(product, customer)
      assert Loans.list() == [loan]
    end

    test "list/1 return loan when filtered with customer_id and status=active", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: customer.id, status: "active"}) == [loan]
    end

    test "list/1 return loan when filtered with customer_id and status=pending", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: customer.id, status: "pending"}) == [loan]
    end

    test "list/1 return loan when filtered with customer_id only", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: customer.id}) == [loan]
    end

    test "list/1 return loan when filtered values are null", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: nil}) == [loan]
    end

    test "check_active_loan/1 check if customer has active loan and return error", %{
      product: product,
      customer: customer
    } do
      _loan = loan_fixture(product, customer)
      assert {:error, :customer_has_active_loan} = Loans.check_active_loan(customer.id)
    end

    test "check_active_loan/1 return error when customer id is nil" do
      assert {:error, :error_checking_active_loans} = Loans.check_active_loan(nil)
    end

    test "get/1 return loan valid loan is is passed", %{
      product: product,
      customer: customer
    } do
      created_loan = loan_fixture(product, customer)
      assert {:ok, %Loan{} = loan} = Loans.get(created_loan.id)
      assert created_loan == loan
    end

    test "create_loan/1 with valid data creates a loan that require approval process", %{
      product: product,
      customer: customer
    } do
      product = Products.fetch_configs(product)
      config = Products.build_configuration_map(product.configuration)

      loan_amount = 1000
      commission_value = String.to_integer(config["loanComission"].value) / 1.0

      commission =
        cond do
          config["commissionType"].value === "flat" ->
            commission_value

          true ->
            commission_value / 100 * loan_amount
        end

      assert {:ok, %Loan{} = loan} =
               Loans.create_loan(product, customer, %{
                 "amount" => loan_amount,
                 "created_by" => customer.id,
                 "customer_id" => customer.id
               })

      loan_with_schedule = Repo.preload(loan, :loan_repayments)
      assert length(loan_with_schedule.loan_repayments) == 1

      assert loan.meta == nil
      assert loan.status == "pending"
      assert loan.term == String.to_integer(config["loanTerm"].value)
      assert loan.uuid != nil
      assert loan.customer_id == customer.id
      assert loan.product_id == product.id
      assert loan.amount == Decimal.new(loan_amount)
      assert loan.commission == Decimal.from_float(commission)
      assert loan.maturity_date == nil
      assert loan.duration == String.to_integer(config["loanDuration"].value)
      assert loan.disbursed_on == nil
      assert loan.closed_on == nil

      # repayment schedule
      [schedule | _] = loan_with_schedule.loan_repayments
      assert schedule.installment_date == nil
      assert schedule.commission == loan.commission
      assert schedule.principal_amount == loan.amount
      assert schedule.status == "pending"
      assert schedule.meta == nil
      assert schedule.penalty_count == 0
      assert schedule.next_penalty_date == nil
      assert schedule.penalty_fee == Decimal.new(0)
    end

    # test "create_loan/3 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Loans.create_loan(@invalid_attrs)
    # end

    # test "update_loan/2 with valid data updates the loan" do
    #   loan = loan_fixture()

    #   update_attrs = %{
    #     meta: %{},
    #     status: "some updated status",
    #     term: 43,
    #     uuid: "7488a646-e31f-11e4-aace-600308960668",
    #     customer_id: 43,
    #     product_id: 43,
    #     amount: "456.7",
    #     commission: "456.7",
    #     maturity_date: ~D[2024-07-15],
    #     duration: 43,
    #     disbursed_on: ~D[2024-07-15],
    #     closed_on: ~D[2024-07-15],
    #     created_by: 43,
    #     updated_by: 43
    #   }

    #   assert {:ok, %Loan{} = loan} = Loans.update_loan(loan, update_attrs)
    #   assert loan.meta == %{}
    #   assert loan.status == "some updated status"
    #   assert loan.term == 43
    #   assert loan.uuid == "7488a646-e31f-11e4-aace-600308960668"
    #   assert loan.customer_id == 43
    #   assert loan.product_id == 43
    #   assert loan.amount == Decimal.new("456.7")
    #   assert loan.commission == Decimal.new("456.7")
    #   assert loan.maturity_date == ~D[2024-07-15]
    #   assert loan.duration == 43
    #   assert loan.disbursed_on == ~D[2024-07-15]
    #   assert loan.closed_on == ~D[2024-07-15]
    #   assert loan.created_by == 43
    #   assert loan.updated_by == 43
    # end

    # test "update_loan/2 with invalid data returns error changeset" do
    #   loan = loan_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Loans.update_loan(loan, @invalid_attrs)
    #   assert loan == Loans.get_loan!(loan.id)
    # end

    # test "delete_loan/1 deletes the loan" do
    #   loan = loan_fixture()
    #   assert {:ok, %Loan{}} = Loans.delete_loan(loan)
    #   assert_raise Ecto.NoResultsError, fn -> Loans.get_loan!(loan.id) end
    # end

    # test "change_loan/1 returns a loan changeset" do
    #   loan = loan_fixture()
    #   assert %Ecto.Changeset{} = Loans.change_loan(loan)
    # end
  end

  defp create_product(_) do
    product = create_loan_product_fixture()
    %{product: product}
  end

  defp create_customer(_) do
    customer = Fundsjet.CustomersFixtures.customer_fixture()
    %{customer: customer}
  end

  defp create_config(%{product: product}) do
    _ = create_loan_configuration_fixture(product)
    %{product: product}
  end
end
