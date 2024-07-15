defmodule Fundsjet.LoansFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fundsjet.Loans` context.
  """

  @doc """
  Generate a loan.
  """
  def loan_fixture(attrs \\ %{}) do
    {:ok, loan} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        closed_on: ~D[2024-07-14],
        commission: "120.5",
        created_by: 42,
        customer_id: 42,
        disbursed_on: ~D[2024-07-14],
        duration: 42,
        maturity_date: ~D[2024-07-14],
        meta: %{},
        product_id: 42,
        status: "some status",
        term: 42,
        updated_by: 42,
        uuid: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Fundsjet.Loans.create_loan()

    loan
  end
end
