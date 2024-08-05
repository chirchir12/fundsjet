defmodule Fundsjet.LoansFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fundsjet.Loans` context.
  """
  alias Fundsjet.Customers.Customer
  alias Fundsjet.Products.Product

  @doc """
  Generate a loan.
  """
  def loan_fixture(%Product{} = product, %Customer{id: customer_id} = customer, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        "amount" => 100,
        "customer_id" => customer_id,
        "created_by" => customer_id
      })

    {:ok, loan} = Fundsjet.Loans.create_loan(product, customer, attrs)
    loan
  end

  def create_loan_product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        code: "personal_loan",
        description: "Personal Loan",
        type: "loans",
        currency: "KES",
        is_enabled: true,
        name: "test Product",
        start_date: ~D[2024-07-12],
        require_approval: true,
        require_docs: true,
        automatic_disbursement: true,
        disbursement_fee: 5.0,
        loan_duration: 30,
        loan_term: 1,
        loan_comission: 10,
        commission_type: "percent",
        loan_penalty: 5,
        penalty_type: "percent",
        penalty_duration: 100,
        penalty_after: 5
      })
      |> Fundsjet.Products.create()

    product
  end
end
