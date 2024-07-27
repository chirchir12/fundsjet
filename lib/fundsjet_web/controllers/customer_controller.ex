defmodule FundsjetWeb.CustomerController do
  use FundsjetWeb, :controller

  alias Fundsjet.Customers
  alias Fundsjet.Customers.Customer

  action_fallback FundsjetWeb.FallbackController

  def index(conn, _params) do
    customers = Customers.list_customers()
    render(conn, :index, customers: customers)
  end

  def create(conn, %{"params" => customer_params}) do
    with {:ok, %Customer{} = customer} <- Customers.create_customer(customer_params) do
      conn
      |> put_status(:created)
      |> render(:show, customer: customer)
    end
  end

  def show(conn, %{"id" => uuid}) do
    with {:ok, customer} <- Customers.get_by(:uuid, uuid) do
      conn
      |> render(:show, customer: customer)
    end
  end

  def update(conn, %{"id" => uuid, "params" => params}) do
    with {:ok, customer} <- Customers.get_by(:uuid, uuid),
         {:ok, %Customer{} = updated_customer} <- Customers.update_customer(customer, params) do
      conn
      |> render(:show, customer: updated_customer)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    with {:ok, customer} <- Customers.get_by(:uuid, uuid),
         {:ok, %Customer{}} <- Customers.delete_customer(customer) do
      send_resp(conn, :no_content, "")
    end
  end
end
