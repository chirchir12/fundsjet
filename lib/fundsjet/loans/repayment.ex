defmodule Fundsjet.Loans.Repayment do

  use Ecto.Schema
  import Ecto.Changeset

  schema "loan_repayments" do
    field :amount, :decimal
    field :paid_on, :utc_datetime
    field :ref_id, :string
    field :meta, :map
    timestamps(type: :utc_datetime)
    # loan_id
    belongs_to :loan, Fundsjet.Loans.Loan
    # loan_schedule_id
    belongs_to :loan_schedule, Fundsjet.Loans.LoanSchedule
  end


  def changeset(repayment, attrs \\ %{}) do
    repayment
    |> cast(attrs, [:amount, :paid_on, :ref_id, :meta, :loan_id, :loan_schedule_id])
    |> validate_required([:amount, :paid_on, :loan_id, :meta, :loan_schedule_id])
    |> validate_number(:amount, greater_than: 0)
  end





end
