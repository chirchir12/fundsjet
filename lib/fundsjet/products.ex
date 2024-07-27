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
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Producct{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Producct{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
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
  def update_product(%Product{} = product, attrs) do
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
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking producct changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def product_exists?(product_code) do
    query = from p in Product, where: p.code == ^product_code
    Repo.exists?(query)
  end

  def get_by_code(code) do
    case Repo.get_by(Product, code: code) do
      nil ->
        {:error, :product_not_found}

      product ->
        product = Repo.preload(product, :configuration)
        {:ok, product}
    end
  end

  def get_configuration(list_configs) when length(list_configs) > 0 do
    Enum.reduce(list_configs, %{}, &reduce_config/2)
  end

  def get_configuration(_) do
    %{}
  end

  defp reduce_config(%Configuration{name: name} = config, acc) do
    acc = Map.put_new(acc, name, config)
    acc
  end
end
