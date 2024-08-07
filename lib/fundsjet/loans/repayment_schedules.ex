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

  defp generate_schedules(%Product{} = product, %Loan{} = loan) do
    1..product.loan_term
    |> Enum.map(fn term ->
      %LoanRepaymentSchedule{
        loan_id: loan.id,
        status: "pending",
        installment_amount:
          (Decimal.to_float(loan.amount) + Decimal.to_float(loan.commission)) / product.loan_term,
        installment_date: Date.add(loan.disbursed_on, term * product.loan_duration)
      }
    end)
  end
end
