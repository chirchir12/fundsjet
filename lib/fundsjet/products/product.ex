defmodule Fundsjet.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

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
    :approval_meta,
    :documents_meta,
    :additional_info
  ]
  @required [
    :code,
    :name,
    :require_approval,
    :require_docs,
    :description,
    :automatic_disbursement
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
    field :automatic_disbursement, :boolean, default: false
    field :updated_by, :integer
    field :created_by, :integer
    field :require_approval, :boolean, default: false
    field :require_docs, :boolean, default: false
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
  end
end
