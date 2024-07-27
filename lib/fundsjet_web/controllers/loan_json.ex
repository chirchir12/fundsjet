defmodule FundsjetWeb.LoanJSON do
  alias Fundsjet.Loans.Loan
  alias Fundsjet.Loans.LoanReview

  @doc """
  Renders a list of loans.
  """
  def index(%{loans: loans}) do
    %{result: for(loan <- loans, do: data(loan))}
  end

  def index(%{reviews: reviews}) do
    %{result: for(review <- reviews, do: data(review))}
  end

  @doc """
  Renders a single loan.
  """
  def show(%{loan: loan}) do
    %{result: data(loan)}
  end

  def show(%{review: review}) do
    %{result: data(review)}
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

  defp data(%LoanReview{} = review) do
    %{
      id: review.id,
      loan_id: review.loan_id,
      staff_id: review.staff_id,
      status: review.status,
      priority: review.priority,
      comment: review.comment
    }
  end
end
