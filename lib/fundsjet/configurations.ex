defmodule Fundsjet.Products.Configurations do
  alias Fundsjet.Products.Configuration
  alias Fundsjet.Repo
  import Ecto.Query

  @doc """
  Creates configurations in the database.

  This function can handle both single configuration maps and lists of configuration maps.

  ## Parameters

    - `config_arr`: A list of configuration maps to be inserted into the database.
    - `config`: A single configuration map to be inserted into the database.

  ## Examples

    Creating multiple configurations in a transaction:

        iex> configs = [
        ...>   %{name: "config1", value: "value1"},
        ...>   %{name: "config2", value: "value2"}
        ...> ]
        iex> Fundsjet.Products.Configurations.create(configs)
        {:ok, _} # If all configurations are inserted successfully
        {:error, changeset} # If any configuration insert fails

    Creating a single configuration:

        iex> config = %{name: "config1", value: "value1"}
        iex> Fundsjet.Products.Configurations.create(config)
        {:ok, %Configuration{}}
        {:error, changeset}

  ## Returns

    - For a list of configurations:
      - `{:ok, _}` if all configurations are inserted successfully.
      - `{:error, changeset}` if any configuration insert fails, and the transaction is rolled back.
    - For a single configuration:
      - `{:ok, %Configuration{}}` if the configuration is inserted successfully.
      - `{:error, changeset}` if the insert fails.
  """
  def create(config_arr) when is_list(config_arr) do
    Repo.transaction(fn ->
      Enum.each(config_arr, fn config ->
        changeset = Configuration.changeset(%Configuration{}, config)

        case Repo.insert(changeset) do
          {:ok, _} -> :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
    end)
  end

  def create(config) do
    %Configuration{}
    |> Configuration.changeset(config)
    |> Repo.insert()
  end

  @doc """
  Fetches a configuration from the database based on the product ID and name.

  ## Parameters

    - `product_id`: The ID of the product to which the configuration belongs.
    - `name`: The name of the configuration to fetch.

  ## Examples

        iex> Fundsjet.Products.Configurations.get(1, "config_name")
        {:ok, %Configuration{}}

        iex> Fundsjet.Products.Configurations.get(1, "non_existent_name")
        {:error, :configuration_not_found}

  ## Returns

    - `{:ok, %Configuration{}}` if a configuration is found.
    - `{:error, :configuration_not_found}` if no configuration is found.
  """
  def get(product_id, name) do
    query = from c in Configuration, where: c.product_id == ^product_id and c.name == ^name

    case Repo.one(query) do
      nil ->
        {:error, :configuration_not_found}

      config ->
        {:ok, config}
    end
  end

  @doc """
  Fetches a configuration from the database based on its ID.

  ## Parameters

    - `id`: The ID of the configuration to fetch.

  ## Examples

        iex> Fundsjet.Products.Configurations.get(1)
        {:ok, %Configuration{}}

        iex> Fundsjet.Products.Configurations.get(999)
        {:error, :configuration_not_found}

  ## Returns

    - `{:ok, %Configuration{}}` if a configuration is found.
    - `{:error, :configuration_not_found}` if no configuration is found.
  """
  def get(id) do
    case Repo.get(Configuration, id) do
      nil ->
        {:error, :configuration_not_found}

      config ->
        {:ok, config}
    end
  end

  @doc """
  Updates a configuration in the database.

  ## Parameters

    - `config`: A `%Configuration{}` struct representing the existing configuration to be updated.
    - `attrs`: A map of attributes to update in the configuration.

  ## Examples

        iex> config = Repo.get(Configuration, 1)
        iex> attrs = %{value: "new_value"}
        iex> Fundsjet.Products.Configurations.update(config, attrs)
        {:ok, %Configuration{}}

        iex> config = Repo.get(Configuration, 1)
        iex> invalid_attrs = %{value: nil}
        iex> Fundsjet.Products.Configurations.update(config, invalid_attrs)
        {:error, changeset}

  ## Returns

    - `{:ok, %Configuration{}}` if the configuration is successfully updated.
    - `{:error, changeset}` if the update fails due to validation errors or other issues.
  """
  def update(%Configuration{} = config, attrs) do
    config
    |> Configuration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Fetches all configurations associated with a given product ID.

  ## Parameters

    - `product_id`: The ID of the product whose configurations are to be fetched.

  ## Examples

        iex> Fundsjet.Products.Configurations.list(1)
        [
          %Configuration{id: 1, name: "config1", value: "value1", product_id: 1},
          %Configuration{id: 2, name: "config2", value: "value2", product_id: 1}
        ]

  ## Returns

    - A list of `%Configuration{}` structs associated with the given product ID.
  """
  def list(product_id) do
    query = from c in Configuration, where: c.product_id == ^product_id
    Repo.all(query)
  end

  @doc """
  Fetches all configurations from the database.

  ## Examples

        iex> Fundsjet.Products.Configurations.list()
        [
          %Configuration{id: 1, name: "config1", value: "value1", product_id: 1},
          %Configuration{id: 2, name: "config2", value: "value2", product_id: 1},
          %Configuration{id: 3, name: "config3", value: "value3", product_id: 2}
        ]

  ## Returns

    - A list of all `%Configuration{}` structs in the database.
  """
  def list() do
    Repo.all(Configuration)
  end

  @doc """
  Deletes a given configuration from the database.

  ## Parameters

    - `config`: A `%Configuration{}` struct representing the configuration to be deleted.

  ## Examples

        iex> config = Repo.get(Configuration, 1)
        iex> Fundsjet.Products.Configurations.delete(config)
        {:ok, %Configuration{}}

        iex> config = %Configuration{id: -1}
        iex> Fundsjet.Products.Configurations.delete(config)
        {:error, changeset}

  ## Returns

    - `{:ok, %Configuration{}}` if the configuration is successfully deleted.
    - `{:error, changeset}` if the deletion fails.
  """

  def delete(%Configuration{} = config) do
    Repo.delete(config)
  end
end
