defmodule Fundsjet.ConfigurationFixtures do
  def configuration_fixture(attrs \\ %{}) do
    {:ok, config} =
      attrs
      |> Enum.into(%{
        "name" => "name1",
        "value" => "value1",
        "description" => "description"
      })
      |> Fundsjet.Products.Configurations.create()

    config
  end
end
