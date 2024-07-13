defmodule Fundsjet.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @permitted [
    :customer_number,
    :uuid,
    :first_name,
    :last_name,
    :phone_number,
    :email,
    :identification_type,
    :identification_number,
    :profile_pic,
    :is_enabled
  ]

  @required [
    :first_name,
    :last_name,
    :phone_number,
    :email,
    :identification_type,
    :identification_number,
    :is_enabled
  ]

  schema "customers" do
    field :customer_number, :string
    field :uuid, Ecto.UUID
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :email, :string
    field :identification_type, :string
    field :identification_number, :string
    field :profile_pic, :string
    field :is_enabled, :boolean
    timestamps(type: :utc_datetime)
    belongs_to :user, Fundsjet.Identity.User
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> maybe_put_uuid()
    |> put_downcased_email()
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

  defp put_downcased_email(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    changeset |> put_change(:email, email |> String.downcase())
  end

  defp put_downcased_email(changeset), do: changeset
end
