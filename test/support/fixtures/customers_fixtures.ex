defmodule Fundsjet.CustomersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fundsjet.Customers` context.
  """

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        "customer_number" => "1234",
        "email" => "test@mail.com",
        "first_name" => "first_name",
        "identification_number" => "4535422",
        "identification_type" => "national_id",
        "last_name" => "last_name",
        "phone_number" => "254111111111",
        "profile_pic" => "profile_pic"
      })
      |> Fundsjet.Customers.create()

    customer
  end
end
