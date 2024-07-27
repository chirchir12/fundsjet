defmodule Fundsjet.Loans.Loan do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed_status [
    "pending",
    "paid",
    "disbursed",
    "in_review",
    "approved",
    "rejected"
  ]

  @permitted [
    :product_id,
    :customer_id,
    :uuid,
    :amount,
    :commission,
    :maturity_date,
    :duration,
    :status,
    :term,
    :disbursed_on,
    :closed_on,
    :created_by,
    :updated_by,
    :meta
  ]

  @required [
    :product_id,
    :customer_id,
    :amount,
    :commission,
    :duration,
    :status,
    :term,
    :created_by
  ]

  schema "loans" do
    field :uuid, Ecto.UUID
    field :amount, :decimal
    field :commission, :decimal
    field :maturity_date, :date
    field :duration, :integer
    field :status, :string
    field :term, :integer
    field :disbursed_on, :date
    field :closed_on, :date
    field :created_by, :integer
    field :updated_by, :integer
    field :meta, :map
    timestamps(type: :utc_datetime)
    # customer_id
    belongs_to :customer, Fundsjet.Customers.Customer
    # product_id
    belongs_to :product, Fundsjet.Products.Product

    has_many :loan_repayments, Fundsjet.Loans.LoanRepaymentSchedule
    has_many :approvers, Fundsjet.Loans.LoanApprovers
  end

  @doc false
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> maybe_put_uuid()
    |> unique_constraint(:uuid)
    |> validate_inclusion(:status, @allowed_status)
  end

  defp maybe_put_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    if changeset.data.id do
      changeset
    else
      case get_field(changeset, :uuid) do
        nil -> changeset |> put_change(:uuid, Ecto.UUID.generate())
        _ -> changeset
      end
    end
  end

  defp maybe_put_uuid(changeset), do: changeset
end
