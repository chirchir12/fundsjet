defmodule Fundsjet.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @permitted [
    :code,
    :name,
    :status,
    :currency,
    :start_date,
    :end_date,
    :is_enabled,
    :updated_by,
    :created_by,
    :require_approval,
    :require_docs,
    :approval_meta,
    :documents_meta,
    :additional_info
  ]
  @required [
    :code,
    :name,
    :require_approval,
    :require_docs
  ]

  schema "products" do
    field :code, :string
    field :name, :string
    field :status, :string, default: "approved"
    field :currency, :string
    field :start_date, :date
    field :end_date, :date
    field :is_enabled, :boolean, default: true
    field :updated_by, :integer
    field :created_by, :integer
    field :require_approval, :boolean, default: false
    field :require_docs, :boolean, default: false
    field :approval_meta, {:array, :map}
    field :documents_meta, {:array, :map}
    field :additional_info, :map

    timestamps(type: :utc_datetime)
    has_many :configuration, Fundsjet.Products.Configuration
  end

  @doc false
  def changeset(producct, attrs) do
    producct
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:code)
  end
end
