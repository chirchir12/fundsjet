defmodule Fundsjet.Loans.Loan do
  use Ecto.Schema
  import Ecto.Changeset
  # todo validate statuses

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
    :maturity_date,
    :duration,
    :status,
    :term,
    :disbursed_on,
    :created_by,
    :updated_by,
    :meta
  ]

  schema "loans" do
    field :uuid, Ecto.UUID, default: Ecto.UUID.generate()
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

    has_many :loan_repayments, Fundsjet.Loans.LoanRepayment
  end

  @doc false
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:uuid)
  end
end
