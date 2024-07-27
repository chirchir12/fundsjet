defmodule Fundsjet.Loans.LoanRepaymentSchedule do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed_status [
    "pending",
    "paid",
    "late"
  ]

  @permitted [
    :loan_id,
    :installment_date,
    :principal_amount,
    :commission,
    :penalty_fee,
    :status,
    :paid_on,
    :next_penalty_date,
    :penalty_count,
    :meta
  ]

  @required [
    :loan_id,
    :principal_amount,
    :commission,
    :penalty_fee,
    :status
  ]

  schema "loan_repayment_schedule" do
    field :installment_date, :date
    field :principal_amount, :decimal
    field :commission, :decimal
    field :penalty_fee, :decimal
    field :status, :string
    field :paid_on, :utc_datetime
    field :next_penalty_date, :date
    field :penalty_count, :integer
    field :meta, :map

    timestamps(type: :utc_datetime)
    # loan_id
    belongs_to :loan, Fundsjet.Loans.Loan
  end

  @doc false
  def changeset(repayment, attrs) do
    repayment
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> validate_inclusion(:status,  @allowed_status )
  end
end
