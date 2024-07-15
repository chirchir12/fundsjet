defmodule FundsjetWeb.LoanController do
  use FundsjetWeb, :controller

  alias Fundsjet.Loans
  alias Fundsjet.Loans.Loan

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    loans = Loans.list_loans()
    render(conn, :index, loans: loans)
  end

  def create(conn, %{"loan" => loan_params}) do
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

  def delete(conn, %{"id" => id}) do
    loan = Loans.get_loan!(id)

    with {:ok, %Loan{}} <- Loans.delete_loan(loan) do
      send_resp(conn, :no_content, "")
    end
  end
end
