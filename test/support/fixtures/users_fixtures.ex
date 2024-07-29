defmodule Fundsjet.Identity.UsersFixtures do
  def create_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        "email" => "email@email.com",
        "first_name" => "first_name",
        "last_name" => "last_name",
        "primary_phone" => "primary_phone",
        "type" => "staff",
        "username" => "username",
        "password" => "password"
      })
      |> Fundsjet.Identity.Users.create()

    user
  end
end
