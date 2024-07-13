defmodule Fundsjet.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fundsjet.Products` context.
  """

  @doc """
  Generate a producct.
  """
  def producct_fixture(attrs \\ %{}) do
    {:ok, producct} =
      attrs
      |> Enum.into(%{
        code: "some code",
        created_by: 42,
        currency: "some currency",
        end_date: ~D[2024-07-12],
        is_enabled: true,
        name: "some name",
        require_approval: true,
        require_docs: true,
        start_date: ~D[2024-07-12],
        status: "some status",
        updated_by: 42
      })
      |> Fundsjet.Products.create_producct()

    producct
  end
end
