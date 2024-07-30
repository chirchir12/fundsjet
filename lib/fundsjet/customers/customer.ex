defmodule Fundsjet.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  import Fundsjet.Helpers

  # todo support other countries
  @phone_number_regex ~r/^(254\d{9})$/
  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

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
    has_many :loans, Fundsjet.Loans.Loan
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> maybe_put_uuid()
    |> put_downcased_email()
    |> unique_constraint(:email)
    |> unique_constraint(:phone_number)
    |> unique_constraint(:identification_number)
    |> unique_constraint(:customer_number)
    |> validate_inclusion(:identification_type, identification_types(),
      message: "unsupported identification type"
    )
    |> validate_phone_number()
    |> validate_format(:email, @mail_regex, message: "invalid email")
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

  defp validate_phone_number(
         %Ecto.Changeset{valid?: true, changes: %{phone_number: phone}} = changeset
       ) do
    if phone =~ @phone_number_regex do
      changeset
    else
      add_error(changeset, :phone_number, "invalid phone number")
    end
  end

  defp validate_phone_number(changeset), do: changeset
end
