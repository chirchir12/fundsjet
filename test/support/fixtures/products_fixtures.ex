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
        currency: "KES",
        end_date: ~D[2024-07-12],
        is_enabled: true,
        name: "test Product",
        require_approval: true,
        require_docs: true,
        start_date: ~D[2024-07-12],
        status: "approved"
      })
      |> Fundsjet.Products.create()

    product
  end
end
