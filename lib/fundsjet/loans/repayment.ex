defmodule Fundsjet.Loans.Repayment do
  alias Fundsjet.Repo
  use Ecto.Schema
  import Ecto.Changeset
  alias Fundsjet.Loans.LoanSchedule

  schema "loan_repayments" do
    field :amount, :decimal
    field :paid_on, :utc_datetime
    field :ref_id, :string
    field :meta, :map
    timestamps(type: :utc_datetime)
    # loan_id
    belongs_to :loan, Fundsjet.Loans.Loan
    # loan_schedule_id
    belongs_to :loan_schedule, LoanSchedule
  end

  def changeset(repayment, attrs \\ %{}) do
    repayment
    |> cast(attrs, [:amount, :paid_on, :ref_id, :meta, :loan_id, :loan_schedule_id])
    |> validate_required([:amount, :paid_on, :loan_id, :meta, :loan_schedule_id])
  end

  def add(schedules, params) when length(schedules) > 0 do
    schedules
    |> Enum.map(&repayment(&1, params))
    |> add()
  end

  def add(repayments) when is_list(repayments) do
    Repo.transaction(fn ->
      repayments
      |> Enum.each(fn repayment ->
        changeset = changeset(%__MODULE__{}, repayment)

        case Repo.insert(changeset) do
          {:ok, _} -> {:ok, :ok}
          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
    end)
  end

  defp repayment(%LoanSchedule{} = schedule, params) do

    %{
      loan_id: schedule.loan_id,
      loan_schedule_id: schedule.id,
      amount: schedule.repaid_amount,
      ref_id: Map.get(params, "ref_id") || nil,
      paid_on: Map.get(params, "paid_on", DateTime.utc_now()),
      updated_at: DateTime.utc_now(),
      meta: params
    }
  end
end
