defmodule Fundsjet.Loans.RepaymentSchedules do
  alias Fundsjet.Repo
  import Ecto.Query
  alias Fundsjet.Products.Product
  alias Fundsjet.Loans.{LoanRepaymentSchedule, Loan}

  # note: penalty types: flat, percent, interests, daily, compoind

  def list(loan_id) do
    query = from lr in LoanRepaymentSchedule, where: lr.loan_id == ^loan_id
    Repo.all(query)
  end

  def add(product, loan) do
    Repo.transaction(fn ->
      generate_schedules(product, loan)
      |> Enum.each(fn schedule ->
        changeset =
          LoanRepaymentSchedule.changeset(%LoanRepaymentSchedule{}, Map.from_struct(schedule))

        case Repo.insert(changeset) do
          {:ok, _} -> :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
    end)
  end

  defp generate_schedules(%Product{loan_term: loan_term, loan_duration: loan_duration}, %Loan{
         disbursed_on: disbursed_on,
         id: loan_id,
         amount: amount,
         commission: comission
       }) do
    1..loan_term
    |> Enum.map(fn term ->
      %LoanRepaymentSchedule{
        loan_id: loan_id,
        status: "pending",
        installment_amount: (Decimal.to_float(amount) + Decimal.to_float(comission)) / loan_term,
        installment_date: Date.add(disbursed_on, term * loan_duration)
      }
    end)
  end
end
