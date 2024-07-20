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
  alias Fundsjet.Loans.LoanRepayment
  alias Fundsjet.Loans.LoanApprovers

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
         {:ok, loan} <- save_loan(product, new_atrrs),
         {:ok, _repayment} <- save_repayment(loan, product) do
      {:ok, loan}
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

  def add_loan_approver(params) do
    attrs = %{
      loan_id: Map.get(params, "loan_id"),
      staff_id: Map.get(params, "staff_id"),
      status: "pending",
      priority: Map.get(params, "priority", 1)
    }

    %LoanApprovers{}
    |> LoanApprovers.changeset(attrs)
    |> Repo.insert()

  end

  def list_loan_approvers(loan_id) do
    query = from a in LoanApprovers, where: a.loan_id == ^ loan_id
    Repo.all(query)
  end

  def get_loan_review(loan_id, staff_id) do
    query = from a in LoanApprovers, where: a.staff_id == ^staff_id and a.loan_id == ^loan_id
    case Repo.one(query) do
      nil ->
        {:error, :loan_reviewer_not_avaialable}
      reviewer ->
        {:ok, reviewer}
    end
  end

  def add_review(params) do
    loan_id = Map.get(params, "loan_id")
    staff_id = Map.get(params, "staff_id")

    with loan <- get_loan!(loan_id),
    {:ok, old_review} <- get_loan_review(loan_id, staff_id),
    {:ok, new_review} <- add_loan_review(old_review, params) do
          _ = update_loan(loan, %{status: "in_review"})
          {:ok, new_review}
    end
  end

  defp save_loan(product, attrs) do
    loan_attrs = create_loan_attrs(product, attrs)

    %Loan{}
    |> Loan.changeset(loan_attrs)
    |> Repo.insert()
  end

  defp save_repayment(loan, product) do
    repayment_attrs = create_loan_repayment_attrs(loan, product)

    %LoanRepayment{}
    |> LoanRepayment.changeset(repayment_attrs)
    |> Repo.insert()
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
      maturity_date:
        calc_loan_maturity(product.require_approval, configuration["loanDuration"].value),
      duration: String.to_integer(configuration["loanDuration"].value),
      status: calc_status(product.require_approval),
      term: String.to_integer(configuration["loanTerm"].value),
      disbursed_on: calc_disbursed_on(product.require_approval),
      created_by: Map.get(attrs, "created_by")
    }

    loan_attrs
  end

  defp create_loan_repayment_attrs(loan, %Product{} = product) do
    repayment_attrs = %{
      loan_id: loan.id,
      installment_date: calc_installmet_date(product.require_approval, loan.maturity_date),
      principal_amount: loan.amount,
      commission: loan.commission,
      penalty_fee: 0,
      status: "pending",
      next_penalty_date: calc_next_penalty_date(product.require_approval, loan.maturity_date),
      penalty_count: 0
    }

    repayment_attrs
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

  defp calc_loan_maturity(require_approval, duration, today \\ Date.utc_today()) do
    case require_approval do
      true ->
        nil

      false ->
        Date.add(today, String.to_integer(duration))
    end
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
  end

  defp calc_installmet_date(require_approval, maturity_date) do
    case require_approval do
      false ->
        maturity_date

      true ->
        nil
    end
  end

  defp calc_next_penalty_date(require_approval, maturity_date) do
    case require_approval do
      false ->
        Date.add(maturity_date, 1)

      true ->
        nil
    end
  end

  defp add_loan_review(current_review, new_review) do
    current_review
      |> LoanApprovers.changeset(new_review)
      |> Repo.update()
  end

end
