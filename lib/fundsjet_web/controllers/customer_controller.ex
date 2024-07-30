defmodule FundsjetWeb.CustomerController do
  use FundsjetWeb, :controller

  alias Fundsjet.Customers
  alias Fundsjet.Customers.Customer

  action_fallback FundsjetWeb.FallbackController

  plug FundsjetWeb.AddAuthUserPlug

  def index(conn, _params) do
    customers = Customers.list()
    render(conn, :index, customers: customers)
  end

  def create(conn, %{"params" => params}) do
    with {:ok, %Customer{} = customer} <- Customers.create(params) do
      conn
      |> put_status(:created)
      |> render(:show, customer: customer)
    end
  end

  def show(conn, %{"id" => uuid}) do
    with {:ok, customer} <- Customers.get(:uuid, uuid) do
      conn
      |> render(:show, customer: customer)
    end
  end

  def update(conn, %{"id" => uuid, "params" => params}) do
    with {:ok, customer} <- Customers.get(:uuid, uuid),
         {:ok, %Customer{} = updated_customer} <- Customers.update(customer, params) do
      conn
      |> render(:show, customer: updated_customer)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with {:ok, customer} <- Customers.get(:uuid, uuid),
         {:ok, %Customer{}} <- Customers.delete(customer) do
      send_resp(conn, :no_content, "")
    end
  end
end
