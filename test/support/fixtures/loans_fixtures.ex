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
    attrs =
      attrs
      |> Enum.into(%{
        "code" => "loanProduct",
        "name" => "loan product",
        "status" => "approved",
        "currency" => "KES",
        "is_enabled" => true,
        "require_approval" => true,
        "require_docs" => true
      })

    {:ok, product} = Fundsjet.Products.create(attrs)
    product
  end

  def create_loan_configuration_fixture(%Product{id: product_id}) do
    _ =
      [
        %{
          name: "loanDuration",
          value: "30",
          description: "loan Duration in days",
          product_id: product_id
        },
        %{
          name: "repaymentTerm",
          value: "1",
          description: "Repayment is repaid after maturity",
          product_id: product_id
        },
        %{
          name: "loanComission",
          value: "10",
          description: "Loan commission",
          product_id: product_id
        },
        %{
          name: "loanTerm",
          value: "1",
          description: "Loan Term for Repayment schedul",
          product_id: product_id
        },
        %{
          name: "commissionType",
          value: "percent",
          description: "Loan commission type",
          product_id: product_id
        },
        %{
          name: "loanPenalty",
          value: "50",
          description: "Loan Penalty",
          product_id: product_id
        },
        %{
          name: "penaltyType",
          value: "flat",
          description: "Loan Penalty type",
          product_id: product_id
        },
        %{
          name: "penaltyDuration",
          value: "60",
          description: "maximum days to apply penalty",
          product_id: product_id
        },
        %{
          name: "penaltyAfter",
          value: "5",
          description: "number of days to apply penalty after last penalty is applied",
          product_id: product_id
        }
      ]
      |> Fundsjet.Products.Configurations.create()

    :ok
  end
end
