defmodule Fundsjet.Identity.User do
  use Ecto.Schema
  import Ecto.Changeset

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  @permitted [
    :uuid,
    :username,
    :email,
    :type,
    :first_name,
    :last_name,
    :primary_phone,
    :is_active,
    :password,
    :email_verified
  ]
  @required [
    :username,
    :email,
    :type,
    :first_name,
    :last_name,
    :primary_phone,
    :is_active,
    :email_verified
  ]

  schema "users" do
    field :type, :string
    field :username, :string
    field :uuid, Ecto.UUID
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    field :primary_phone, :string
    field :password, :string, virtual: true
    field :is_active, :boolean
    field :email_verified, :boolean

    timestamps(type: :utc_datetime)
    has_one :customer, Fundsjet.Customers.Customer
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> maybe_validate_password()
    |> validate_format(:email, @mail_regex, message: "invalid email")
    |> unique_constraint(:uuid)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_downcased_email()
    |> maybe_put_uuid()
    |> put_password_hash()
  end

  defp maybe_validate_password(changeset) do
    if changeset.data.id do
      changeset
    else
      changeset
      |> validate_required([:password])
      |> validate_length(:password, min: 6)
    end
  end

  defp put_downcased_email(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    changeset |> put_change(:email, email |> String.downcase())
  end

  defp put_downcased_email(changeset), do: changeset

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

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}} = changeset) do
    changeset |> put_change(:password_hash, Argon2.hash_pwd_salt(pass))
  end

  defp put_password_hash(changeset), do: changeset
end
