defmodule FundsjetWeb.CustomerJSON do
  alias Fundsjet.Customers.Customer

  @doc """
  Renders a list of customers.
  """
  def index(%{customers: customers}) do
    %{data: for(customer <- customers, do: data(customer))}
  end

  @doc """
  Renders a single customer.
  """
  def show(%{customer: customer}) do
    %{data: data(customer)}
  end

  defp data(%Customer{} = customer) do
    %{
      id: customer.uuid,
      user_id: customer.user_id,
      customer_number: customer.customer_number,
      first_name: customer.first_name,
      last_name: customer.last_name,
      phone_number: customer.phone_number,
      email: customer.email,
      identification_type: customer.identification_type,
      identification_number: customer.identification_number,
      profile_pic: customer.profile_pic
    }
  end
end
