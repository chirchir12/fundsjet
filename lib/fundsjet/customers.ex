defmodule Fundsjet.Customers do
  @moduledoc """
  The Customers context.
  """

  import Ecto.Query, warn: false
  alias Fundsjet.Repo

  alias Fundsjet.Customers.Customer

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list()
      [%Customer{}, ...]

  """
  def list do
    Repo.all(Customer)
  end

  @doc """
  Fetches a customer from the database based on the provided UUID.

  ## Parameters

    - `:uuid`: A fixed atom indicating that the search is by UUID.
    - `uuid`: The UUID of the customer to fetch.

  ## Examples

        iex>  Fundsjet.Customers.get(:uuid, "123e4567-e89b-12d3-a456-426614174000")
        {:ok, %Customer{}}

        iex>  Fundsjet.Customers.get(:uuid, "non-existent-uuid")
        {:error, :customer_not_found}

  ## Returns

    - `{:ok, %Customer{}}` if a customer with the given UUID is found.
    - `{:error, :customer_not_found}` if no customer with the given UUID is found.
  """
  def get(:uuid, uuid) do
    case Repo.get_by(Customer, uuid: uuid) do
      nil ->
        {:error, :customer_not_found}

      customer ->
        {:ok, customer}
    end
  end

  @doc """
  Fetches a customer from the database based on the provided ID.

  ## Parameters

    - `id`: The ID of the customer to fetch.

  ## Examples

        iex> Fundsjet.Customers.get(1)
        {:ok, %Customer{}}

        iex> Fundsjet.Customers.get(999)
        {:error, :customer_not_found}

  ## Returns

    - `{:ok, %Customer{}}` if a customer with the given ID is found.
    - `{:error, :customer_not_found}` if no customer with the given ID is found.
  """
  def get(id) do
    case Repo.get(Customer, id) do
      nil ->
        {:error, :customer_not_found}

      customer ->
        {:ok, customer}
    end
  end

  @doc """
  Creates a customer.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Customer{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    attrs = Map.put_new(attrs, "is_enabled", true)

    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete(customer)
      {:ok, %Customer{}}

      iex> delete(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Customer{} = customer) do
    Repo.delete(customer)
  end
end
