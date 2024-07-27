defmodule Fundsjet.Loans do
  @moduledoc """
  The Loans context.
  """
  alias Fundsjet.Identity.User
  alias Fundsjet.Customers.Customer
  alias Fundsjet.Repo
  import Ecto.Query, warn: false
  alias Fundsjet.Products
  alias Fundsjet.Products.Product
  alias Fundsjet.Loans.{Loan, LoanRepaymentSchedule, LoanReviewers}
  require Logger

  @doc """
  Lists loans based on the given customer ID.

  ## Parameters

    - `customer_id`: The ID of the customer whose loans are to be listed. Can be any type.

  ## Returns

    - A list of loans for the given customer ID if it is an integer.
    - A list of all loans.

  ## Examples

      iex> list_loans(1)
      [%Loan{}, ...]

      iex> list_loans("invalid_id")
      [%Loan{}, ...]
  """
  def list_loans(customer_id) when is_integer(customer_id) do
    query = from l in Loan, where: l.customer_id == ^customer_id
    Repo.all(query)
  end

  def list_loans(nil) do
    Repo.all(Loan)
  end

  @doc """
  Fetches a loan record by its ID.

  ## Parameters

    - `id`: The ID of the loan to be fetched. Can be any type.

  ## Returns

    - `{:ok, loan}`: If a loan with the given ID is found.
    - `{:error, :loan_not_found}`: If no loan with the given ID is found or if the ID is not an integer.

  ## Examples

    iex> get(1)
    {:ok, %Loan{}}

    iex> get(999)
    {:error, :loan_not_found}

    iex> get("invalid_id")
    {:error, :loan_not_found}
  """
  def get(id) when is_integer(id) do
    case Repo.get(Loan, id) do
      nil ->
        {:error, :loan_not_found}

      loan ->
        {:ok, loan}
    end
  end

  def get(_) do
    {:error, :loan_not_found}
  end

  @doc """
  Creates a loan for a given product and customer if the customer is enabled.

  ## Parameters

    - `product`: A `%Product{}` struct representing the product for which the loan is being created.
    - `customer`: A `%Customer{}` struct representing the customer for whom the loan is being created.
    - `params`: A map containing the parameters required to create the loan.

  ## Returns

    - `{:ok, loan}`: If the loan is successfully created and the repayment schedule is saved.
    - `{:error, :customer_is_disabled}`: If the customer is disabled.
    - `{:error, reason}`: If there is an error in saving the loan or the repayment schedule.

  ## Examples

      iex> create_loan(%Product{id: 1, ...}, %Customer{id: 1, is_enabled: true}, %{amount: 1000, term: 12})
      {:ok, %Loan{id: 1, product_id: 1, customer_id: 1, ...}}

      iex> create_loan(%Product{id: 1, ...}, %Customer{id: 1, is_enabled: false}, %{amount: 1000, term: 12})
      {:error, :customer_is_disabled}

      iex> create_loan(%Product{id: 1, ...}, %Customer{id: 1, is_enabled: true}, %{amount: 1000, term: 12})
      {:error, reason}
  """
  def create_loan(%Product{} = product, %Customer{is_enabled: true}, params) do
    with {:ok, loan} <- save_loan(product, params),
         {:ok, _repayment} <- save_repayment_schedule(loan, product) do
      {:ok, loan}
    end
  end

  def create_loan(_product, %Customer{is_enabled: false}, _params) do
    {:error, :customer_is_disabled}
  end

  @doc """
  Updates a loan.

  ## Examples

      iex> update_loan(loan, %{field: new_value})
      {:ok, %Loan{}}

      iex> update_loan(loan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_loan(%Loan{} = loan, params) do
    loan
    |> Loan.changeset(params)
    |> Repo.update()
  end

  @doc """
  Updates a loan repayment schedule with the given parameters.

  ## Parameters

    - `repayment_schedule`: A `%LoanRepaymentSchedule{}` struct representing the repayment schedule to be updated.
    - `params`: A map containing the parameters to update the repayment schedule.

  ## Returns

    - `{:ok, %LoanRepaymentSchedule{}}`: If the repayment schedule is successfully updated.
    - `{:error, %Ecto.Changeset{}}`: If there is an error in updating the repayment schedule, returns an error tuple with the changeset.

  ## Examples

      iex> update_repayment_schedule(%LoanRepaymentSchedule{id: 1, ...}, %{amount: 200})
      {:ok, %LoanRepaymentSchedule{id: 1, amount: 200, ...}}

      iex> update_repayment_schedule(%LoanRepaymentSchedule{id: 1, ...}, %{invalid_param: "value"})
      {:error, %Ecto.Changeset{...}}
  """
  def update_repayment_schedule(%LoanRepaymentSchedule{} = repayment_schedule, params) do
    repayment_schedule
    |> LoanRepaymentSchedule.changeset(params)
    |> Repo.update()
  end

  @doc """
  Fetches the repayment schedule for a given loan ID.

  ## Parameters

    - `loan_id`: The ID of the loan whose repayment schedule is to be fetched.

  ## Returns

    - `{:ok, %LoanRepaymentSchedule{}}`: If the repayment schedule is found.
    - `{:error, :repayment_schedule_not_found}`: If no repayment schedule is found for the given loan ID.

  ## Examples

      iex> get_repayment_schedule(1)
      {:ok, %LoanRepaymentSchedule{id: 1, loan_id: 1, ...}}

      iex> get_repayment_schedule(999)
      {:error, :repayment_schedule_not_found}
  """
  def get_repayment_schedule(loan_id) do
    query = from r in LoanRepaymentSchedule, where: r.loan_id == ^loan_id

    case Repo.one(query) do
      nil ->
        {:error, :repayment_schedule_not_found}

      schedule ->
        {:ok, schedule}
    end
  end

  # LOAN REVIEWS

  def add_reviewer(%Loan{} = loan, %User{} = staff, priority) do
    with {:ok, reviewer} <- LoanReviewers.add_reviewer(loan, staff, priority) do
      {:ok, reviewer}
    end
  end

  def list_reviews(loan_id) do
    with reviews <- LoanReviewers.get_reviews(loan_id) do
      {:ok, reviews}
    end
  end

  def add_review(review, params) do
    with {:ok, review} <- LoanReviewers.add_review(review, params) do
      {:ok, review}
    end
  end

  def get_review(loan_id, staff_id) do
    with {:ok, review} <- LoanReviewers.get_review(loan_id, staff_id) do
      {:ok, review}
    end
  end

  def loan_has_pending_reviews?(loan_id) do
    LoanReviewers.is_in_review?(loan_id)
  end

  def approve_loan(%Loan{status: "in_review"} = loan, status) do
    with {:ok, loan} = update_loan(loan, %{status: status}) do
      {:ok, loan}
    end
  end

  def approve_loan(loan, _params) do
    Logger.error("Cannot approve loan: #{inspect(loan)}")
    {:error, :error_approving_loan}
  end

  def disburse_loan(loan, repayment_schedule, disbursement_date \\ Date.utc_today())

  def disburse_loan(
        %Loan{status: "approved"} = loan,
        %LoanRepaymentSchedule{} = repayment_schedule,
        disbursement_date
      ) do
    maturity_date = calc_loan_maturity(false, loan.duration, disbursement_date)

    loan_attrs = %{
      maturity_date: maturity_date,
      disbursed_on: disbursement_date,
      status: "dibursed"
    }

    {:ok, loan} = update_loan(loan, loan_attrs)

    repayment_schedule_attrs = %{
      installment_date: calc_installmet_date(false, maturity_date),
      next_penalty_date: calc_next_penalty_date(false, maturity_date)
    }

    with {:ok, loan} <- update_loan(loan, loan_attrs),
         {:ok, _repayment} <-
           update_repayment_schedule(repayment_schedule, repayment_schedule_attrs) do
      {:ok, loan}
    end
  end

  def disburse_loan(%Loan{status: "dibursed"}, _repayment_schedule, _disbursement_date) do
    {:error, :loan_has_been_disbursed}
  end

  def disburse_loan(%Loan{status: "rejected"}, _repayment_schedule, _disbursement_date) do
    {:error, :cannot_approve_reject_loan}
  end

  def disburse_loan(_) do
    {:error, :loan_has_not_been_approved}
  end

  def repay_loan(
        %Loan{} = loan,
        %LoanRepaymentSchedule{} = repayment_schedule,
        params
      ) do
    # todo. this should repayment full amount for now
    repayment_amount = params |> Map.get("amount")

    total_loan_amount =
      Decimal.to_float(repayment_schedule.principal_amount) +
        Decimal.to_float(repayment_schedule.commission) +
        Decimal.to_float(repayment_schedule.penalty_fee)

    if repayment_amount < total_loan_amount do
      {:error, :repayment_amount_lower_than_loan_amount}
    else
      repayment_schedule_attrs = %{
        status: "paid",
        meta: Map.merge(repayment_schedule.meta || %{}, params),
        paid_on: DateTime.utc_now()
      }

      loan_attrs = %{
        status: "paid",
        closed_on: Date.utc_today()
      }

      with {:ok, _repayment} <-
             update_repayment_schedule(repayment_schedule, repayment_schedule_attrs),
           {:ok, loan} <- update_loan(loan, loan_attrs) do
        {:ok, loan}
      end
    end
  end

  def repay_loan(
        %Loan{status: "paid"},
        _schedule,
        _params
      ) do
    {:error, :loan_already_repaid}
  end

  defp save_loan(product, attrs) do
    loan_attrs = create_loan_attrs(product, attrs)

    %Loan{}
    |> Loan.changeset(loan_attrs)
    |> Repo.insert()
  end

  defp save_repayment_schedule(loan, product) do
    repayment_schedule_attrs = create_loan_repayment_schedule_attrs(loan, product)

    %LoanRepaymentSchedule{}
    |> LoanRepaymentSchedule.changeset(repayment_schedule_attrs)
    |> Repo.insert()
  end

  defp create_loan_attrs(%Product{} = product, attrs) do
    amount = Map.get(attrs, "amount")
    configuration = Products.get_configuration(product.configuration)
    disbursed_on = calc_disbursed_on(product.require_approval, Map.get(attrs, "disbursed_on"))

    %{
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
        calc_loan_maturity(
          product.require_approval,
          String.to_integer(configuration["loanDuration"].value),
          disbursed_on
        ),
      duration: String.to_integer(configuration["loanDuration"].value),
      status: calc_status(product.require_approval),
      term: String.to_integer(configuration["loanTerm"].value),
      disbursed_on: disbursed_on,
      created_by: Map.get(attrs, "created_by")
    }
  end

  defp create_loan_repayment_schedule_attrs(loan, %Product{} = product) do
    %{
      loan_id: loan.id,
      installment_date: calc_installmet_date(product.require_approval, loan.maturity_date),
      principal_amount: loan.amount,
      commission: loan.commission,
      penalty_fee: 0,
      status: "pending",
      next_penalty_date: calc_next_penalty_date(product.require_approval, loan.maturity_date),
      penalty_count: 0
    }
  end

  defp calc_commission(type, value, amount) do
    case type do
      "percent" ->
        1 / 100 * String.to_integer(value) * amount

      "flat" ->
        String.to_integer(value)
    end
  end

  defp calc_loan_maturity(require_approval, duration, disbursed_on) do
    case require_approval do
      true ->
        nil

      false ->
        Date.add(disbursed_on, duration)
    end
  end

  defp calc_disbursed_on(require_approval, disbursed_on) do
    case require_approval do
      true ->
        nil

      false ->
        disbursed_on
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
end
