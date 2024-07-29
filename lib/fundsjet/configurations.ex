defmodule Fundsjet.Products.Configurations do
  alias Fundsjet.Products.Configuration
  alias Fundsjet.Repo
  import Ecto.Query

  @doc """
  Create configuration.

  ## Examples

      iex> create_configuration(%{field: value})
      {:ok, %Configuration{}}

      iex> create_configuration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_configurations(config_arr) do
    configs = Enum.map(config_arr, &save_config/1)
    configs
  end

  def update_configuration(%Configuration{} = config, attrs) do
    config
    |> Configuration.changeset(attrs)
    |> Repo.update()
  end

  def list_configuration(product_id) do
    query = from c in Configuration, where: c.product_id == ^product_id
    Repo.all(query)
  end

  def list_configuration() do
    Repo.all(Configuration)
  end

  defp save_config(param) do
    %Configuration{}
    |> Configuration.changeset(param)
    |> Repo.insert()
    |> case do
      {:ok, config} ->
        config
    end
  end

  # todo delete configurations bulk or single
end
