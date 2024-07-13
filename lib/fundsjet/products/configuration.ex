defmodule Fundsjet.Products.Configuration do
  use Ecto.Schema
  import Ecto.Changeset

  @permitted [
    :product_id,
    :name,
    :value,
    :description
  ]

  @required [
    :name,
    :value,
    :description
  ]

  schema "configuration" do
    field :name, :string
    field :value, :string
    field :description, :string
    belongs_to :product, Fundsjet.Products.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint([:name, :product_id])
  end
end
