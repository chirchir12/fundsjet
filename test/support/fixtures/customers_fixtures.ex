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
        customer_number: "some customer_number",
        email: "some email",
        first_name: "some first_name",
        identification_number: "some identification_number",
        identification_type: "some identification_type",
        last_name: "some last_name",
        phone_number: "some phone_number",
        profile_pic: "some profile_pic",
        user_id: 42
      })
      |> Fundsjet.Customers.create_customer()

    customer
  end
end
