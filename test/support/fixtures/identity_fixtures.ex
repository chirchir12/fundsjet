defmodule Fundsjet.IdentityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fundsjet.Identity` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "some first_name",
        last_name: "some last_name",
        primary_phone: "some primary_phone",
        type: "some type",
        username: "some username",
        uuid: "some uuid"
      })
      |> Fundsjet.Identity.create_user()

    user
  end
end
