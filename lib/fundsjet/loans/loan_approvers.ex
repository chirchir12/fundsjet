defmodule Fundsjet.Loans.LoanApprovers do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed_status [
    "pending",
    "approved",
    "rejected"
  ]

  @permitted [
    :staff_id,
    :loan_id,
    :priority,
    :status,
    :comment
  ]

  @required [
    :staff_id,
    :loan_id,
    :priority,
    :status
  ]

  schema "loan_approvers" do
    field :priority, :integer
    field :status, :string
    field :comment, :string
    timestamps(type: :utc_datetime)
    # loan_id
    belongs_to :loan, Fundsjet.Loans.Loan
    belongs_to :staff, Fundsjet.Identity.User
  end

  @doc false
  def changeset(approvers, attrs) do
    approvers
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint([:loan_id, :staff_id])
    |> validate_inclusion(:status, @allowed_status)
  end
end
