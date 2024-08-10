defmodule FundsjetWeb.ProductJSON do
  alias Fundsjet.Products.Product
  alias Fundsjet.Products.Configuration

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{result: for(product <- products, do: data(product))}
  end

  def index(%{configs: configs}) do
    %{result: for(config <- configs, do: data(config))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{result: data(product)}
  end

  def show(%{config: config}) do
    %{result: data(config)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      name: product.name,
      code: product.code,
      currency: product.currency,
      start_date: product.start_date,
      end_date: product.end_date,
      status: product.status,
      is_enabled: product.is_enabled,
      updated_by: product.updated_by,
      created_by: product.created_by,
      require_approval: product.require_approval,
      require_docs: product.require_docs,
      approval_meta: product.approval_meta,
      documents_meta: product.documents_meta,
      additional_info: product.additional_info,
      disbursement_fee: product.disbursement_fee,
      loan_comission: product.loan_comission,
      loan_duration: product.loan_duration,
      loan_penalty: product.loan_penalty,
      penalty_type: product.penalty_type,
      penalty_duration: product.penalty_duration,
      penalty_after: product.penalty_after,
      loan_term: product.loan_term,
      description: product.description

    }
  end

  defp data(%Configuration{} = config) do
    %{
      id: config.id,
      product_id: config.product_id,
      name: config.name,
      value: config.value,
      description: config.description
    }
  end
end
