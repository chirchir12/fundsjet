defmodule Fundsjet.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @product_types ["loans"]
  @commission_type ["flat", "percent"]
  @penalty_type ["flat", "percent"]

  @permitted [
    :code,
    :name,
    :type,
    :description,
    :status,
    :currency,
    :start_date,
    :end_date,
    :is_enabled,
    :updated_by,
    :created_by,
    :require_approval,
    :require_docs,
    :automatic_disbursement,
    # specific to loan
    :disbursement_fee,
    :loan_duration,
    :loan_term,
    :loan_comission,
    :commission_type,
    :loan_penalty,
    :penalty_type,
    :penalty_duration,
    :penalty_after,
    :approval_meta,
    :documents_meta,
    :additional_info
  ]
  @required [
    :code,
    :name,
    :description,
    :type
  ]

  @required_for_loan [
    :require_approval,
    :require_docs,
    :automatic_disbursement,
    :disbursement_fee,
    :loan_duration,
    :loan_term,
    :loan_comission,
    :commission_type,
    :loan_penalty,
    :penalty_type,
    :penalty_duration,
    :penalty_after
  ]

  schema "products" do
    field :code, :string
    field :name, :string
    field :status, :string, default: "approved"
    field :type, :string, default: "loans"
    field :description, :string
    field :currency, :string
    field :start_date, :date
    field :end_date, :date
    field :is_enabled, :boolean, default: true
    field :updated_by, :integer
    field :created_by, :integer

    # specific to loan
    field :require_approval, :boolean, default: false
    field :require_docs, :boolean, default: false
    field :automatic_disbursement, :boolean, default: false
    field :disbursement_fee, :decimal
    field :loan_duration, :integer
    field :loan_term, :integer
    field :loan_comission, :decimal
    field :commission_type, :string
    field :loan_penalty, :decimal
    field :penalty_type, :string
    field :penalty_duration, :integer
    field :penalty_after, :integer


    # meta
    field :approval_meta, {:array, :map}
    field :documents_meta, {:array, :map}
    field :additional_info, :map

    timestamps(type: :utc_datetime)
    has_many :configuration, Fundsjet.Products.Configuration
    has_many :loans, Fundsjet.Loans.Loan
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:code)
    |> validate_inclusion(:type, @product_types)
    |> loan_changeset()
  end

  defp loan_changeset(%Ecto.Changeset{valid?: true, changes: %{type: "loans"}} = changeset) do
    changeset
    |> validate_required(@required_for_loan)
    |> validate_inclusion(:commission_type, @commission_type, message: "invalid commission type. Only flat and percent are allowed")
    |> validate_inclusion(:penalty_type, @penalty_type, message: "invalid penalty type. only flat and percent are allowed")
  end

  defp loan_changeset(changeset), do: changeset
end
