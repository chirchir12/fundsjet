defmodule FundsjetWeb.LoanJSON do
  alias Fundsjet.Loans.Loan

  @doc """
  Renders a list of loans.
  """
  def index(%{loans: loans}) do
    %{data: for(loan <- loans, do: data(loan))}
  end

  @doc """
  Renders a single loan.
  """
  def show(%{loan: loan}) do
    %{data: data(loan)}
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
end
