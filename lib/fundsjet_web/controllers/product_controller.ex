defmodule FundsjetWeb.ProductController do
  use FundsjetWeb, :controller

  alias Fundsjet.Products
  alias Fundsjet.Products.{Product, Configurations}
  alias Fundsjet.Identity.{User, Auth}

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    products = Products.list()
    render(conn, :index, products: products)
  end

  def create(conn, %{"params" => params}) do
    with {:ok, %User{id: current_user_id}} <- Auth.get_current_user(conn),
         params <- Map.put_new(params, "created_by", current_user_id),
         {:ok, %Product{} = product} <- Products.create(params) do
      conn
      |> put_status(:created)
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, product} <- Products.get(:id, id) do
      conn
      |> render(:show, product: product)
    end
  end

  def update(conn, %{"id" => id, "params" => params}) do
    with {:ok, %User{id: current_user_id}} <- Auth.get_current_user(conn),
         {:ok, product} <- Products.get(:id, id),
         params <- Map.put_new(params, "updated_by", current_user_id),
         {:ok, %Product{} = product} <- Products.update(product, params) do
      conn
      |> render(:show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, product} <- Products.get(:id, id),
         {:ok, %Product{}} <- Products.delete(product) do
      conn
      |> send_resp(:no_content, "")
    end
  end

  def create_configuration(conn, %{"product_id" => product_id, "params" => params})
      when is_list(params) and length(params) > 0 do
    with {:ok, _product} <- Products.get(:id, product_id),
         params <-
           Enum.map(params, fn param -> Map.put_new(param, "product_id", product_id) end),
         {:ok, :ok} <- Configurations.create(params),
         configs <- Configurations.list(product_id) do
      conn
      |> render(:index, configs: configs)
    end
  end

  def create_configuration(conn, %{"product_id" => product_id, "params" => params}) do
    with {:ok, _product} <- Products.get(:id, product_id),
         params <- Map.put_new(params, "product_id", product_id),
         {:ok, configs} <- Configurations.create(params) do
      conn
      |> render(:index, configs: [configs])
    end
  end
end
