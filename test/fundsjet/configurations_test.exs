defmodule Fundsjet.ConfigurationsTest do
  use Fundsjet.DataCase
  alias Fundsjet.Products.Configurations
  alias Ecto.Changeset

  @invalid_attrs %{
    "name" => nil,
    "value" => nil,
    "product_id" => nil,
    "description" => nil
  }

  describe "configurations" do
    setup [:create_product]

    alias Fundsjet.Products.Configuration
    import Fundsjet.ConfigurationFixtures

    test "list/0 returns all configurations", %{product: product} do
      assert Configurations.list() == []

      configuration = configuration_fixture(%{"product_id" => product.id})
      assert Configurations.list() == [configuration]
    end

    test "list/1 returns all configurations by product id", %{product: product} do
      assert Configurations.list(999) == []

      configuration = configuration_fixture(%{"product_id" => product.id})
      assert Configurations.list(product.id) == [configuration]
    end

    test "get/1 returns the configuration with given id", %{product: product} do
      assert {:error, :configuration_not_found} == Configurations.get(-1)

      configuration = configuration_fixture(%{"product_id" => product.id})
      assert {:ok, %Configuration{} = config} = Configurations.get(configuration.id)
      assert config == configuration
    end

    test "get/1 returns the configuration with given product_id and name", %{product: product} do
      assert {:error, :configuration_not_found} == Configurations.get(-1, "noname")

      configuration = configuration_fixture(%{"product_id" => product.id})
      assert {:ok, %Configuration{} = config} = Configurations.get(product.id, configuration.name)
      assert config == configuration
    end

    test "create/1 create configs from list of valid attrs", %{product: product} do
      config1 = %{
        "product_id" => product.id,
        "name" => "name1",
        "value" => "value1",
        "description" => "description"
      }

      config2 = %{
        "product_id" => product.id,
        "name" => "name2",
        "value" => "value1",
        "description" => "description"
      }

      assert {:ok, :ok} = Configurations.create([config1, config2])

      config3 = %{
        "product_id" => product.id,
        "name" => "name2",
        "value" => "value1",
        "description" => "description"
      }

      assert {:error, %Changeset{}} = Configurations.create([config1, config2, config3])
    end

    test "create/1 create configuration from valid attrs", %{product: product} do
      config1 = %{
        "product_id" => product.id,
        "name" => "name1",
        "value" => "value1",
        "description" => "description"
      }

      assert {:ok, %Configuration{}} = Configurations.create(config1)

      assert {:error, %Changeset{}} = Configurations.create(config1)
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Configurations.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the configuration", %{product: product} do
      configuration = configuration_fixture(%{"product_id" => product.id})

      attrs = %{
        "product_id" => product.id,
        "name" => "name2",
        "value" => "changed value",
        "description" => "updated description"
      }

      assert {:ok, %Configuration{} = config} = Configurations.update(configuration, attrs)
      assert config.value == "changed value"
      assert config.name == "name2"
    end

    test "delete/1 deletes the configuration", %{product: product} do
      configuration = configuration_fixture(%{"product_id" => product.id})
      assert {:ok, %Configuration{}} = Configurations.delete(configuration)
      assert {:error, :configuration_not_found} = Configurations.get(configuration.id)
    end
  end

  defp create_product(_) do
    product = Fundsjet.ProductsFixtures.product_fixture()
    %{product: product}
  end
end
