defmodule Fundsjet.Loans do
  @moduledoc """
  The Loans context.
  """
  alias Fundsjet.Identity.User
  alias Fundsjet.Customers.Customer
  alias Fundsjet.Repo
  import Ecto.Query, warn: false
  alias Fundsjet.Products.Product
  alias Fundsjet.Loans.{Loan, LoanRepaymentSchedule, LoanReviewers, FilterLoan}
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
  def list(%FilterLoan{customer_id: customer_id, status: "active"})
      when not is_nil(customer_id) do
    query = from l in Loan, where: l.customer_id == ^customer_id and l.status != "paid"
    Repo.all(query)
  end

  def list(%FilterLoan{customer_id: customer_id, status: status})
      when not is_nil(customer_id) and not is_nil(status) do
    query = from l in Loan, where: l.customer_id == ^customer_id and l.status == ^status
    Repo.all(query)
  end

  def list(%FilterLoan{customer_id: customer_id}) when not is_nil(customer_id) do
    query = from l in Loan, where: l.customer_id == ^customer_id
    Repo.all(query)
  end

  def list(%FilterLoan{customer_id: nil, status: nil}) do
    list()
  end

  def list() do
    Repo.all(Loan)
  end

  def check_active_loan(customer_id) when not is_nil(customer_id) do
    case list(%FilterLoan{customer_id: customer_id, status: "active"}) do
      [] ->
        {:ok, :no_active_loan}

      [_ | _] ->
        {:error, :customer_has_active_loan}
    end
  end

  def check_active_loan(nil) do
    {:error, :error_checking_active_loans}
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
  def create_loan(%Product{} = product, %Customer{is_enabled: true, id: customer_id}, params) do
    with {:ok, _valid_changeset} <- validate_loan(params),
         {:ok, :no_active_loan} <- check_active_loan(customer_id),
         {:ok, loan} <- save_loan(product, params),
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

  def add_review(%Loan{status: "pending"} = loan, review, params) do
    with {:ok, review} <- LoanReviewers.add_review(review, params),
         {:ok, _loan} <- put_in_review(loan) do
      {:ok, review}
    end
  end

  def add_review(%Loan{status: "in_review"}, review, params) do
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

  def approve_loan(%Loan{status: "in_review"} = loan, params) do
    with {:ok, loan} = update_loan(loan, params) do
      {:ok, loan}
    end
  end

  def approve_loan(%Loan{status: "approved"} = loan, _params) do
    Logger.error("Cannot approve loan: #{inspect(loan)}")
    {:error, :loan_already_approved}
  end

  def approve_loan(loan, _params) do
    Logger.error("Cannot approve loan: #{inspect(loan.uuid)} - #{inspect(loan.status)}")
    {:error, :error_approving_loan}
  end

  def put_in_review(%Loan{status: "pending"} = loan) do
    with {:ok, loan} = update_loan(loan, %{status: "in_review"}) do
      {:ok, loan}
    end
  end

  def put_in_review(%Loan{status: "in_review"} = loan) do
    {:ok, loan}
  end

  def put_in_review(_) do
    {:error, :error_reviewing_loan}
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
      status: "disbursed"
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

  def disburse_loan(%Loan{status: "disbursed"}, _repayment_schedule, _disbursement_date) do
    {:error, :loan_has_been_disbursed}
  end

  def disburse_loan(%Loan{status: "rejected"}, _repayment_schedule, _disbursement_date) do
    {:error, :cannot_approve_reject_loan}
  end

  def disburse_loan(_) do
    {:error, :loan_has_not_been_approved}
  end

  def repay_loan(
        %Loan{status: status} = loan,
        %LoanRepaymentSchedule{} = repayment_schedule,
        params
      )
      when status in ["late", "disbursed"] do
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

  def repay_loan(
        _loan,
        _schedule,
        _params
      ) do
    {:error, :error_repaying_loan}
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
    disbursed_on = calc_disbursed_on(product.require_approval, Map.get(attrs, "disbursed_on"))

    %{
      amount: amount,
      customer_id: Map.get(attrs, "customer_id"),
      product_id: product.id,
      commission:
        calc_commission(
          product.commission_type,
          Decimal.to_float(product.loan_comission),
          amount
        ),
      maturity_date:
        calc_loan_maturity(
          product.require_approval,
          product.loan_duration,
          disbursed_on
        ),
      duration: product.loan_duration,
      status: calc_status(product.require_approval),
      term: product.loan_term,
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

  defp calc_commission("percent", value, amount) do
    value / 100 * amount
  end

  defp calc_commission("flat", value, _amount) do
    value
  end

  defp calc_commission(_type, _value, nil) do
    nil
  end

  defp calc_loan_maturity(require_approval, duration, disbursed_on)
       when is_boolean(require_approval) and not is_nil(disbursed_on) do
    if require_approval do
      nil
    else
      Date.add(disbursed_on, duration)
    end
  end

  defp calc_loan_maturity(_require_approval, _duration, nil) do
    nil
  end

  defp calc_disbursed_on(require_approval, disbursed_on) when is_boolean(require_approval) do
    if require_approval do
      nil
    else
      disbursed_on
    end
  end

  defp calc_disbursed_on(_require_approval, nil) do
    nil
  end

  defp calc_status(require_approval) when is_boolean(require_approval) do
    if require_approval do
      "pending"
    else
      "approved"
    end
  end

  defp calc_installmet_date(require_approval, maturity_date) when is_boolean(require_approval) do
    if require_approval do
      nil
    else
      maturity_date
    end
  end

  defp calc_next_penalty_date(require_approval, maturity_date)
       when is_boolean(require_approval) and not is_nil(maturity_date) do
    if require_approval do
      nil
    else
      Date.add(maturity_date, 1)
    end
  end

  defp calc_next_penalty_date(_require_approval, nil) do
    nil
  end

  defp validate_loan(attrs) do
    changeset = Loan.changeset(%Loan{}, attrs)

    case changeset.valid? do
      true -> {:ok, changeset}
      false -> {:error, changeset}
    end
  end
end
