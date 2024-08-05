defmodule Fundsjet.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fundsjet.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        code: "testProduct",
        description: "test product",
        type: "savings",
        currency: "KES",
        end_date: ~D[2024-07-12],
        is_enabled: true,
        name: "test Product",
        start_date: ~D[2024-07-12],
        status: "approved"
      })
      |> Fundsjet.Products.create()

    product
  end

  def loan_product_fixture(attrs \\ %{}) do
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
        disbursement_fee: 5,
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
