defmodule Fundsjet.Identity.Auth.Login do
  use Ecto.Schema
  import Ecto.Changeset

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  embedded_schema do
    field :email, :string
    field :password, :string
  end

  def changeset(t, attrs \\ %{}) do
    t
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, @mail_regex, message: "invalid email")
    |> put_downcased_email()
  end

  defp put_downcased_email(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    changeset |> put_change(:email, email |> String.downcase())
  end

  defp put_downcased_email(changeset), do: changeset
end
