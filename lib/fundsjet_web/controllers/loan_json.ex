defmodule FundsjetWeb.LoanJSON do
  alias Fundsjet.Loans.Loan
  alias Fundsjet.Loans.LoanApprovers

  @doc """
  Renders a list of loans.
  """
  def index(%{loans: loans}) do
    %{result: for(loan <- loans, do: data(loan))}
  end

  def index(%{approvers: approvers}) do
    %{result: for(approver <- approvers, do: data(approver))}
  end

  @doc """
  Renders a single loan.
  """
  def show(%{loan: loan}) do
    %{result: data(loan)}
  end

  def show(%{approver: approver}) do
    %{result: data(approver)}
  end

  defp data(%Loan{} = loan) do
    %{
      id: loan.id,
      customer_id: loan.customer_id,
      product_id: loan.product_id,
      amount: loan.amount,
      commission: loan.commission,
      maturity_date: loan.maturity_date,
      status: loan.status,
      uuid: loan.uuid,
      duration: loan.duration,
      term: loan.term,
      disbursed_on: loan.disbursed_on,
      closed_on: loan.closed_on,
      created_by: loan.created_by,
      updated_by: loan.updated_by,
      meta: loan.meta
    }
  end

  defp data(%LoanApprovers{} = approver) do
    %{
      id: approver.id,
      loan_id: approver.loan_id,
      staff_id: approver.staff_id,
      status: approver.status,
      priority: approver.priority,
      comment: approver.comment
    }
  end
end
