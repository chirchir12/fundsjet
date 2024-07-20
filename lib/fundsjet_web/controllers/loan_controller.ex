defmodule FundsjetWeb.LoanController do
  use FundsjetWeb, :controller

  alias Fundsjet.Loans
  alias Fundsjet.Loans.Loan
  alias Fundsjet.Identity.GuardianHelper
  alias Fundsjet.Identity.User


  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    loans = Loans.list_loans()
    render(conn, :index, loans: loans)
  end

  def create(conn, %{"loan" => loan_params}) do
    {:ok, %User{id: current_user_id}} = GuardianHelper.get_current_user(conn)
    loan_params = Map.put_new(loan_params, "created_by", current_user_id)

    with {:ok, %Loan{} = loan} <- Loans.create_loan(loan_params) do
      conn
      |> put_status(:created)
      |> render(:show, loan: loan)
    end
  end

  def show(conn, %{"id" => id}) do
    loan = Loans.get_loan!(id)
    render(conn, :show, loan: loan)
  end

  def update(conn, %{"id" => id, "loan" => loan_params}) do
    loan = Loans.get_loan!(id)

    with {:ok, %Loan{} = loan} <- Loans.update_loan(loan, loan_params) do
      render(conn, :show, loan: loan)
    end
  end


  def add_loan_approver(conn, %{"id" => loan_id, "approver" => params}) do
    params = params |> Map.put_new("loan_id", loan_id)

    with {:ok, approver} <- Loans.add_loan_approver(params) do
      conn
      |> put_status(:created)
      |> render(:show, approver: approver)
    end
  end

  def add_loan_review(conn, %{"id" => loan_id, "approver" => approver, "review" => params}) do
    params =
      params
      |> Map.put_new("loan_id", loan_id)
      |> Map.put_new("staff_id", approver)

    with {:ok, approver} <- Loans.add_review(params) do
      conn
      |> put_status(:ok)
      |> render(:show, approver: approver)
    end
  end

  def list_loan_approvers(conn, %{"id" => loan_id}) do
    with approvers <- Loans.list_loan_approvers(loan_id) do
      conn
      |> put_status(:ok)
      |> render(:index, approvers: approvers)
    end
  end

  def get_loan_review(conn, %{"id" => loan_id, "approver" => staff_id}) do
    with {:ok, approver} <- Loans.get_loan_review(loan_id, staff_id) do
      conn
      |> put_status(:ok)
      |> render(:show, approver: approver)
    end
  end

  def approve_loan(conn, %{"id" => loan_id, "params" => params}) do
    {:ok, %User{id: current_user_id}} = GuardianHelper.get_current_user(conn)
    params = params
            |> Map.put_new("updated_by", current_user_id)
            |> Map.put_new("updated_at", DateTime.utc_now())
    with {:ok, loan} <- Loans.approve_loan(loan_id, params) do
      conn
      |> put_status(:ok)
      |> render(:show, loan: loan)
    end
  end

  def disburse_loan(conn, %{"id" => loan_id}) do
    with {:ok, loan} <- Loans.disburse_loan(loan_id) do
      conn
      |> put_status(:ok)
      |> render(:show, loan: loan)
    end
  end

  def repay_loan(conn, %{"id" => loan_id, "params" => params}) do
    with {:ok, loan} <- Loans.repay_loan(loan_id, params) do
      conn
      |> put_status(:ok)
      |> render(:show, loan: loan)
    end
  end
end
