defmodule Fundsjet.Loans do
  @moduledoc """
  The Loans context.
  """
  alias Fundsjet.Identity.User
  alias Fundsjet.Customers.Customer
  alias Fundsjet.Repo
  import Ecto.Query, warn: false
  alias Fundsjet.Products.Product
  alias Fundsjet.Products

  alias Fundsjet.Loans.{
    Loan,
    LoanSchedule,
    LoanReview,
    FilterLoan,
    Repayment
  }

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
  def create_loan(
        %Product{require_approval: false, automatic_disbursement: true} = product,
        %Customer{is_enabled: true, id: customer_id},
        params
      ) do
    with {:ok, _valid_changeset} <- validate_loan(product, params),
         {:ok, :no_active_loan} <- check_active_loan(customer_id),
         {:ok, loan} <- save_loan(product, params),
         {:ok, _repayment} <- LoanSchedule.add(product, loan) do
      {:ok, loan}
    end
  end

  def create_loan(
        %Product{} = product,
        %Customer{is_enabled: true, id: customer_id},
        params
      ) do
    with {:ok, _valid_changeset} <- validate_loan(product, params),
         {:ok, :no_active_loan} <- check_active_loan(customer_id),
         {:ok, loan} <- save_loan(product, params) do
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

  def get_repayment_schedule(loan_id) do
    LoanSchedule.list(loan_id)
  end

  # LOAN REVIEWS

  def add_reviewer(%Loan{} = loan, %User{} = staff, priority) do
    with {:ok, reviewer} <- LoanReview.add_reviewer(loan, staff, priority) do
      {:ok, reviewer}
    end
  end

  def list_reviews(loan_id) do
    with reviews <- LoanReview.get_reviews(loan_id) do
      {:ok, reviews}
    end
  end

  def add_review(%Loan{status: "pending"} = loan, review, params) do
    with {:ok, review} <- LoanReview.add_review(review, params),
         {:ok, _loan} <- put_in_review(loan) do
      {:ok, review}
    end
  end

  def add_review(%Loan{status: "in_review"}, review, params) do
    with {:ok, review} <- LoanReview.add_review(review, params) do
      {:ok, review}
    end
  end

  def get_review(loan_id, staff_id) do
    with {:ok, review} <- LoanReview.get_review(loan_id, staff_id) do
      {:ok, review}
    end
  end

  def loan_has_pending_reviews?(loan_id) do
    LoanReview.is_in_review?(loan_id)
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

  def disburse_loan(loan, disbursement_date \\ Date.utc_today())

  def disburse_loan(
        %Loan{status: "approved", product_id: product_id} = loan,
        disbursement_date
      ) do
    loan_attrs = %{
      maturity_date: Date.add(disbursement_date, loan.duration),
      disbursed_on: disbursement_date,
      status: "disbursed"
    }

    with {:ok, product} <- Products.get(product_id),
         {:ok, loan} <- update_loan(loan, loan_attrs),
         {:ok, :ok} <- LoanSchedule.add(product, loan) do
      {:ok, loan}
    end
  end

  def disburse_loan(%Loan{status: "disbursed"}, _disbursement_date) do
    {:error, :loan_has_been_disbursed}
  end

  def disburse_loan(%Loan{status: "pending"}, _disbursement_date) do
    {:error, :loan_has_not_been_approved}
  end

  def disburse_loan(%Loan{status: "rejected"}, _disbursement_date) do
    {:error, :cannot_disburse_rejected_loan}
  end

  def repay_loan(%Loan{status: status} = loan, params)
      when status in ["late", "disbursed"] do
    amount = params |> Map.get("amount")

    schedules = LoanSchedule.list(loan.id, "active")

    with {:ok, {repaid_schedules, unpaid_schedules}} <- generate_repayments(schedules, amount),
         {:ok, :ok} <- Repayment.add(repaid_schedules, params),
         {:ok, :ok} <- LoanSchedule.update(repaid_schedules, params) do
      case length(unpaid_schedules) == 0 do
        true ->
          update_loan(loan, %{status: "paid", closed_on: Date.utc_today()})

        false ->
          update_loan(loan, %{status: "partially_repaid"})
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

  defp create_loan_attrs(%Product{} = product, attrs) do
    amount = Map.get(attrs, "amount")
    disbursed_on = calc_disbursed_on(product.require_approval, Map.get(attrs, "disbursed_on"))

    %{
      amount: amount,
      customer_id: Map.get(attrs, "customer_id"),
      product_id: product.id,
      commission: calc_commission(product, amount),
      maturity_date: calc_loan_maturity(product, disbursed_on),
      duration: product.loan_duration,
      status: calc_status(product),
      term: product.loan_term,
      disbursed_on: disbursed_on,
      created_by: Map.get(attrs, "created_by")
    }
  end

  defp calc_commission(%Product{commission_type: "percent", loan_comission: value}, amount) do
    Decimal.to_float(value) / 100 * amount
  end

  defp calc_commission(%Product{commission_type: "flat", loan_comission: value}, _amount) do
    Decimal.to_float(value)
  end

  defp calc_commission(_product, nil) do
    nil
  end

  defp calc_loan_maturity(%Product{} = product, disbursed_on)
       when is_boolean(product.require_approval) and not is_nil(disbursed_on) do
    if product.require_approval do
      nil
    else
      Date.add(disbursed_on, product.loan_duration)
    end
  end

  defp calc_loan_maturity(_product, nil) do
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

  defp calc_status(%Product{require_approval: false, automatic_disbursement: true}) do
    "disbursed"
  end

  defp calc_status(%Product{require_approval: require_approval})
       when is_boolean(require_approval) do
    if require_approval do
      "pending"
    else
      "approved"
    end
  end

  defp validate_loan(
         %Product{automatic_disbursement: true, require_approval: false} = product,
         attrs
       ) do
    changeset = Loan.changeset(product, %Loan{}, attrs)

    case changeset.valid? do
      true -> {:ok, changeset}
      false -> {:error, changeset}
    end
  end

  defp validate_loan(_product, attrs) do
    changeset = Loan.changeset(%Loan{}, attrs)

    case changeset.valid? do
      true -> {:ok, changeset}
      false -> {:error, changeset}
    end
  end

  defp put_in_review(%Loan{status: "pending"} = loan) do
    with {:ok, loan} = update_loan(loan, %{status: "in_review"}) do
      {:ok, loan}
    end
  end

  defp put_in_review(_) do
    {:error, :error_reviewing_loan}
  end

  defp generate_repayments(unpaid_schedules, amount, repaid_schedules \\ []) when amount > 0 do
    unpaid_schedules
    |> gen_repayment_tx(amount, repaid_schedules)
  end

  defp gen_repayment_tx([], _amount, repaid_schedules) do
    {:ok, {repaid_schedules, []}}
  end

  defp gen_repayment_tx(
         [%LoanSchedule{total_amount: total_amount} = schedule | unpaid_schedules],
         amount,
         repaid_schedules
       )
       when amount >= total_amount do
    amount = amount - total_amount
    schedule = %{schedule | repaid_amount: total_amount}

    repaid_schedules = [schedule | repaid_schedules]
    gen_repayment_tx(unpaid_schedules, amount, repaid_schedules)
  end

  defp gen_repayment_tx(
         [%LoanSchedule{total_amount: total_amount} = schedule | unpaid_schedules],
         amount,
         repaid_schedules
       )
       when amount < total_amount do
    schedule = %{schedule | repaid_amount: amount}
    repaid_schedules = [schedule | repaid_schedules]
    {:ok, {repaid_schedules, unpaid_schedules}}
  end
end
