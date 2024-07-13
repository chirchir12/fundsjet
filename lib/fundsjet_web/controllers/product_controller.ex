defmodule FundsjetWeb.ProductController do
  use FundsjetWeb, :controller

  alias Fundsjet.Products
  alias Fundsjet.Products.Product
  alias Fundsjet.Identity.GuardianHelper
  alias Fundsjet.Identity.User
  alias Fundsjet.Products.Cofigurations

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    IO.inspect(product_params)
    {:ok, %User{id: current_user_id}} = GuardianHelper.get_current_user(conn)
    product_params = Map.put_new(product_params, "created_by", current_user_id)

    with {:ok, %Product{} = product} <- Products.create_product(product_params) do
      conn
      |> put_status(:created)
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    {:ok, %User{id: current_user_id}} = GuardianHelper.get_current_user(conn)
    product_params = Map.put_new(product_params, "updated_by", current_user_id)
    product = Products.get_product!(id)

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)

    with {:ok, %Product{}} <- Products.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end

  def create_configuration(conn, %{"product_id" => product_id, "config"=> config_params}) do
    # todo handle cases where this throw an error
    config_params = Enum.map(config_params, fn config -> Map.put_new(config, "product_id", product_id) end )
    with configs <- Cofigurations.create_configurations(config_params) do
      render(conn, :index, configs: configs)
    end
  end
end
