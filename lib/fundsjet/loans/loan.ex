defmodule Fundsjet.Loans.Loan do
  alias Fundsjet.Products.Product
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
    :customer_id,
    :amount,
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
    has_many :loan_reviews, Fundsjet.Loans.LoanReview
  end

  @doc false

  def changeset(%__MODULE__{status: "in_review"} = loan, attrs) do
    loan
    |> cast(attrs, [:status, :updated_by, :updated_at])
    |> validate_required([:status, :updated_by, :updated_at])
    |> validate_inclusion(:status, ["approved", "rejected"],
      message: "invalid loan approval status"
    )
  end

  def changeset(loan, attrs) do
    loan
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> maybe_put_uuid()
    |> unique_constraint(:uuid)
    |> validate_inclusion(:status, @allowed_status)
  end

  def changeset(%Product{automatic_disbursement: true, require_approval: false}, loan, attrs) do
    loan
    |> cast(attrs, @required ++ [:disbursed_on])
    |> validate_required(@required ++ [:disbursed_on])
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
