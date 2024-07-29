defmodule Fundsjet.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Fundsjet.Repo

  alias Fundsjet.Products.Product
  alias Fundsjet.Products.Configuration

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Producct{}, ...]

  """
  def list do
    Repo.all(Product)
  end

  @doc """
  Fetches a product from the database based on the provided identifier type and value.

  ## Parameters

    - `:id`: Fetches a product by its ID.
    - `:code`: Fetches a product by its code.

  ## Examples

    Fetching a product by ID:

        iex> Fundsjet.Products.get(:id, 1)
        {:ok, %Product{}}

        iex> Fundsjet.Products.get(:id, 999)
        {:error, :product_not_found}

    Fetching a product by code:

        iex> Fundsjet.Products.get(:code, "ABC123")
        {:ok, %Product{}}

        iex> Fundsjet.Products.get(:code, "non-existent-code")
        {:error, :product_not_found}

  ## Returns

    - `{:ok, %Product{}}` if a product is found. The product will be preloaded with its configuration.
    - `{:error, :product_not_found}` if no product is found.
  """
  def get(:id, id) do
    case Repo.get(Product, id) do
      nil ->
        {:error, :product_not_found}

      product ->
        {:ok, product}
    end
  end

  def get(:code, code) do
    case Repo.get_by(Product, code: code) do
      nil ->
        {:error, :product_not_found}

      product ->
        {:ok, product}
    end
  end

  @doc """
  Fetches and preloads the configurations associated with a given product.

  ## Parameters

    - `product`: A `%Product{}` struct representing the product for which configurations should be preloaded.

  ## Examples

    Fetching configurations for a product:

        iex> product = Repo.get(Product, 1)
        iex> Fundsjet.Products.fetch_configs(product)
        %Product{
          id: 1,
          name: "Example Product",
          configuration: [%Configuration{id: 1, name: "config1", value: "value1"}]
        }

  ## Returns

    - A `%Product{}` struct with the `:configuration` association preloaded.
  """
  def fetch_configs(%Product{} = product) do
    Repo.preload(product, :configuration)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Producct{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Producct{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Checks if a product with the given code exists in the database.

  ## Parameters

    - `product_code`: The code of the product to check.

  ## Examples

        iex> Fundsjet.Products.exists?("ABC123")
        true

        iex> Fundsjet.Products.exists?("non-existent-code")
        false

  ## Returns

    - `true` if a product with the given code exists.
    - `false` if no product with the given code exists.
  """
  def exists?(product_code) do
    query = from p in Product, where: p.code == ^product_code
    Repo.exists?(query)
  end

  @doc """
  Builds a map of configurations from a list of configuration structs.

  ## Parameters

    - `list_configs`: A list of configuration structs.

  ## Examples

    Building a configuration map from a list of configurations:

        iex> configurations = [
        ...>   %Configuration{name: "config1", value: "value1"},
        ...>   %Configuration{name: "config2", value: "value2"}
        ...> ]
        iex> Fundsjet.Products.build_configuration_map(configurations)
        %{
          "config1" => %Configuration{name: "config1", value: "value1"},
          "config2" => %Configuration{name: "config2", value: "value2"}
        }

    Handling an empty list:

        iex> Fundsjet.Products.build_configuration_map([])
        %{}

  ## Returns

    - A map where each key is the `name` attribute of a configuration struct, and each value is the corresponding configuration struct.
    - An empty map if the input is not a non-empty list.
  """
  def build_configuration_map(list_configs) when length(list_configs) > 0 do
    Enum.reduce(list_configs, %{}, &reduce_config/2)
  end

  def build_configuration_map(_) do
    %{}
  end

  defp reduce_config(%Configuration{name: name} = config, acc) do
    acc = Map.put_new(acc, name, config)
    acc
  end
end
