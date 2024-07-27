defmodule FundsjetWeb.LoanController do
  use FundsjetWeb, :controller

  alias Fundsjet.Loans
  alias Fundsjet.Loans.Loan
  alias Fundsjet.Identity.GuardianHelper
  alias Fundsjet.Identity.User
  alias Fundsjet.Identity
  alias Fundsjet.Products
  alias Fundsjet.Customers
  alias Fundsjet.Customers.Customer

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    loans = Loans.list_loans(nil)
    render(conn, :index, loans: loans)
  end

  def create(conn, %{"params" => params}) do
    # todo check if customer has loan
    with {:ok, %User{id: current_user_id}} <- GuardianHelper.get_current_user(conn),
         {:ok, product} <- Products.get_by_code("loanProduct"),
         {:ok, %Customer{id: customer_id} = customer} <-
           Customers.get_by(:uuid, Map.get(params, "customer_id")),
         params <- Map.put(params, "created_by", current_user_id),
         params <- Map.put(params, "customer_id", customer_id),
         {:ok, loan} <- Loans.create_loan(product, customer, params) do
      conn
      |> put_status(:created)
      |> render(:show, loan: loan)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, loan} <- Loans.get(id) do
      conn
      |> render(:show, loan: loan)
    end
  end

  def update(conn, %{"id" => id, "params" => params}) do
    with {:ok, loan} <- Loans.get(id),
         {:ok, %Loan{} = loan} <- Loans.update_loan(loan, params) do
      conn
      |> render(:show, loan: loan)
    end
  end

  def add_loan_reviewer(conn, %{"id" => loan_id, "params" => params}) do
    with {:ok, staff} <- Identity.get_user_by(:uuid, Map.get(params, "staff_id")),
         {:ok, loan} <- Loans.get(loan_id),
         priority <- Map.get(params, "priority"),
         {:ok, reviewer} <-
           Loans.add_reviewer(loan, staff, priority) do
      conn
      |> put_status(:ok)
      |> render(:show, reviewer: reviewer)
    end
  end

  def add_loan_review(conn, %{"id" => loan_id, "params" => params}) do
    with {:ok, current_review} <- Loans.get_review(loan_id, Map.get(params, "staff_id")),
         params <- Map.put(params, "loan_id", loan_id),
         {:ok, new_review} <- Loans.add_review(current_review, params) do
      conn
      |> put_status(:ok)
      |> render(:show, review: new_review)
    end
  end

  def list_loan_reviews(conn, %{"id" => loan_id}) do
    with {:ok, reviews} <- Loans.list_reviews(loan_id) do
      conn
      |> put_status(:ok)
      |> render(:index, reviews: reviews)
    end
  end

  def approve_loan(conn, %{"id" => loan_id, "params" => params}) do
    with {:ok, %User{id: current_user_id}} <- GuardianHelper.get_current_user(conn),
         {:ok, loan} <- Loans.get(loan_id),
         params <- Map.put_new(params, "updated_by", current_user_id),
         params <- Map.put_new(params, "updated_at", DateTime.utc_now()),
         {:ok, loan} <- Loans.approve_loan(loan, params) do
      conn
      |> put_status(:ok)
      |> render(:show, loan: loan)
    end
  end

  def disburse_loan(conn, %{"id" => loan_id, "params" => params}) do
    with {:ok, loan} <- Loans.get(loan_id),
         {:ok, repayment_schedule} <- Loans.get_repayment_schedule(loan_id),
         disbursed_on <- Map.get(params, "disbursed_on"),
         {:ok, date} <- parse_date(disbursed_on),
         {:ok, loan} <- Loans.disburse_loan(loan, repayment_schedule, date) do
      conn
      |> put_status(:ok)
      |> render(:show, loan: loan)
    end
  end

  def repay_loan(conn, %{"id" => loan_id, "params" => params}) do
    with {:ok, loan} <- Loans.get(loan_id),
         {:ok, repayment_schedule} <- Loans.get_repayment_schedule(loan_id),
         {:ok, loan} <- Loans.repay_loan(loan, repayment_schedule, params) do
      conn
      |> put_status(:ok)
      |> render(:show, loan: loan)
    end
  end

  defp parse_date(date) when is_binary(date) do
    Date.from_iso8601(date)
  end

  defp parse_date(nil) do
    {:ok, Date.utc_today()}
  end

  defp parse_date(date) do
    date
  end
end
