defmodule Fundsjet.IdentityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fundsjet.Identity` context.
  """

  @doc """
  Generate a user.
  """
  def create_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "email@email.com",
        first_name: "first_name",
        last_name: "last_name",
        primary_phone: "primary_phone",
        type: "staff",
        username: "username",
        password: "password"
      })
      |> Fundsjet.Identity.create_user()

    user
  end

  def get_user_fixture(user_id) do
    Fundsjet.Identity.get_user!(user_id)
  end

end
