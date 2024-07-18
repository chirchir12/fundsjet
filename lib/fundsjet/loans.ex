defmodule Fundsjet.Loans do
  @moduledoc """
  The Loans context.
  """

  import Ecto.Query, warn: false
  alias Fundsjet.Customers.Customer
  alias Fundsjet.Repo
  alias Fundsjet.Products
  alias Fundsjet.Products.Product
  alias Fundsjet.Customers
  alias Fundsjet.Loans.Loan

  @doc """
  Returns the list of loans.

  ## Examples

      iex> list_loans()
      [%Loan{}, ...]

  """
  def list_loans do
    Repo.all(Loan)
  end

  @doc """
  Gets a single loan.

  Raises `Ecto.NoResultsError` if the Loan does not exist.

  ## Examples

      iex> get_loan!(123)
      %Loan{}

      iex> get_loan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_loan!(id), do: Repo.get!(Loan, id)

  @doc """
  Creates a loan.

  ## Examples

      iex> create_loan(%{field: value})
      {:ok, %Loan{}}

      iex> create_loan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_loan(attrs \\ %{}) do
    customer_uuid = Map.get(attrs, "customer_id")

    with %Customer{id: customer_id, is_enabled: true} <-
           Customers.get_customer_by!(:uuid, customer_uuid),
         product <- Products.get_product_by!(:code, "loanProduct"),
         {:ok, nil, :customer_has_no_loan} <- get_loan_by(:customer_id, customer_id),
         new_atrrs <- Map.put(attrs, "customer_id", customer_id),
         loan_attrs <- create_loan_attrs(product, new_atrrs) do
      %Loan{}
      |> Loan.changeset(loan_attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Updates a loan.

  ## Examples

      iex> update_loan(loan, %{field: new_value})
      {:ok, %Loan{}}

      iex> update_loan(loan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_loan(%Loan{} = loan, attrs) do
    loan
    |> Loan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a loan.

  ## Examples

      iex> delete_loan(loan)
      {:ok, %Loan{}}

      iex> delete_loan(loan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_loan(%Loan{} = loan) do
    Repo.delete(loan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking loan changes.

  ## Examples

      iex> change_loan(loan)
      %Ecto.Changeset{data: %Loan{}}

  """
  def change_loan(%Loan{} = loan, attrs \\ %{}) do
    Loan.changeset(loan, attrs)
  end

  defp create_loan_attrs(%Product{} = product, attrs) do
    amount = Map.get(attrs, "amount")
    configuration = Products.get_configuration(product.configuration)

    loan_attrs = %{
      amount: amount,
      customer_id: Map.get(attrs, "customer_id"),
      product_id: product.id,
      commission:
        calc_commission(
          configuration["commissionType"].value,
          configuration["loanComission"].value,
          amount
        ),
      maturity_date: calc_loan_maturity(configuration["loanDuration"].value),
      duration: String.to_integer(configuration["loanDuration"].value),
      status: calc_status(product.require_approval),
      term: String.to_integer(configuration["loanTerm"].value),
      disbursed_on: calc_disbursed_on(product.require_approval),
      created_by: Map.get(attrs, "created_by")
    }

    loan_attrs
  end

  def get_loan_by(:customer_id, customer_id) do
    query = from l in Loan, where: l.status != "paid" and l.customer_id == ^customer_id

    case Repo.one(query) do
      nil ->
        {:ok, nil, :customer_has_no_loan}

      loan ->
        {:ok, loan, :customer_already_loan}
    end
  end

  defp calc_commission(type, value, amount) do
    case type do
      "percent" ->
        1 / 100 * String.to_integer(value) * amount

      "flat" ->
        String.to_integer(value)
    end
  end

  defp calc_loan_maturity(duration, today \\ Date.utc_today()) do
    Date.add(today, String.to_integer(duration))
  end

  defp calc_disbursed_on(require_approval) do
    case require_approval do
      true ->
        nil

      false ->
        Date.utc_today()
    end
  end

  defp calc_status(require_approval) do
    case require_approval do
      true ->
        "pending"

      false ->
        "disbursed"
    end

    "pending"
  end
end
