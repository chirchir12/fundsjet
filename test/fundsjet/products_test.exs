defmodule Fundsjet.ProductsTest do
  alias Fundsjet.Products.Configuration
  alias Ecto.Changeset
  use Fundsjet.DataCase

  alias Fundsjet.Products

  describe "products" do
    alias Fundsjet.Products.Product

    import Fundsjet.ProductsFixtures

    @invalid_attrs %{
      "code" => nil,
      "name" => nil,
      "description" => nil
    }

    test "list/0 returns all products" do
      product = product_fixture()
      assert Products.list() == [product]
    end

    test "get/1 returns the product with given id" do
      new_product = product_fixture()
      assert {:ok, product} = Products.get(new_product.id)
      assert new_product == product
    end

    test "get/1 returns the product with invalid id return error" do
      assert {:error, :product_not_found} = Products.get(999)
    end

    test "get/2 returns the product with given code" do
      new_product = product_fixture()
      assert {:ok, product} = Products.get(:code, new_product.code)
      assert new_product == product
    end

    test "get/2 returns the product with invalid code return error" do
      assert {:error, :product_not_found} = Products.get(:code, "invalidCode")
    end

    test "create_product/1 with valid data creates a generic product" do
      valid_attrs = %{
        "code" => "testProduct",
        "name" => "test product",
        "type" => "savings",
        "description" => "product description"
      }

      assert {:ok, %Product{} = product} = Products.create(valid_attrs)
      assert product.code == "testProduct"
      assert product.name == "test product"
      assert product.status == "approved"
      assert product.currency == nil
      assert product.start_date == nil
      assert product.end_date == nil
      assert product.is_enabled == true
      assert product.updated_by == nil
      assert product.created_by == nil
      assert product.require_approval == false
      assert product.require_docs == false
    end

    test "create_product/1 with valid data creates a loan product" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        "loan_duration" => 30,
        "loan_term" => 1,
        "loan_comission" => 10,
        "commission_type" => "percent",
        "loan_penalty" => 5,
        "penalty_type" => "percent",
        "penalty_duration" => 100,
        "penalty_after" => 5
      }

      assert {:ok, %Product{} = product} = Products.create(valid_attrs)
      assert product.code == "personal_loan"
      assert product.name == "personal loan"
      assert product.status == "approved"
      assert product.currency == "KES"
      assert product.start_date != nil
      assert product.end_date == nil
      assert product.is_enabled == true
      assert product.updated_by == nil
      assert product.created_by == nil
      assert product.require_approval == true
      assert product.require_docs == true
      assert product.automatic_disbursement == true
      assert product.disbursement_fee == Decimal.new(5)
      assert product.loan_duration == 30
      assert product.loan_term == 1
      assert product.loan_comission == Decimal.new(10)
      assert product.commission_type == "percent"
      assert product.loan_penalty == Decimal.new(5)
      assert product.penalty_type == "percent"
      assert product.penalty_duration == 100
      assert product.penalty_after == 5
    end

    test "create_product/1 throws error is loan_duration is missing for type loans" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        # "loan_duration" => 30,
        "loan_term" => 1,
        "loan_comission" => 10,
        "commission_type" => "percent",
        "loan_penalty" => 5,
        "penalty_type" => "percent",
        "penalty_duration" => 100,
        "penalty_after" => 5
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 throws error is loan_term is missing for type loans" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        "loan_duration" => 30,
        # "loan_term" => 1,
        "loan_comission" => 10,
        "commission_type" => "percent",
        "loan_penalty" => 5,
        "penalty_type" => "percent",
        "penalty_duration" => 100,
        "penalty_after" => 5
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 throws error is loan_comission is missing for type loans" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        "loan_duration" => 30,
        "loan_term" => 1,
        # "loan_comission" => 10,
        "commission_type" => "percent",
        "loan_penalty" => 5,
        "penalty_type" => "percent",
        "penalty_duration" => 100,
        "penalty_after" => 5
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 throws error is commission_type is missing for type loans" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        "loan_duration" => 30,
        "loan_term" => 1,
        "loan_comission" => 10,
        # "commission_type" => "percent",
        "loan_penalty" => 5,
        "penalty_type" => "percent",
        "penalty_duration" => 100,
        "penalty_after" => 5
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 throws error is loan_penalty is missing for type loans" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        "loan_duration" => 30,
        "loan_term" => 1,
        "loan_comission" => 10,
        "commission_type" => "percent",
        # "loan_penalty" => 5,
        "penalty_type" => "percent",
        "penalty_duration" => 100,
        "penalty_after" => 5
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 throws error is penalty_type is missing for type loans" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        "loan_duration" => 30,
        "loan_term" => 1,
        "loan_comission" => 10,
        "commission_type" => "percent",
        "loan_penalty" => 5,
        # "penalty_type" => "percent",
        "penalty_duration" => 100,
        "penalty_after" => 5
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 throws error is penalty_after is missing for type loans" do
      valid_attrs = %{
        "code" => "personal_loan",
        "description" => "Personal Loan",
        "type" => "loans",
        "currency" => "KES",
        "is_enabled" => true,
        "name" => "personal loan",
        "start_date" => ~D[2024-07-12],
        "require_approval" => true,
        "require_docs" => true,
        "automatic_disbursement" => true,
        "disbursement_fee" => 5,
        "loan_duration" => 30,
        "loan_term" => 1,
        "loan_comission" => 10,
        "commission_type" => "percent",
        "loan_penalty" => 5,
        "penalty_type" => "percent",
        "penalty_duration" => 100
        # "penalty_after" => 5
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 with existing code return error changeset" do
      _ = product_fixture()

      valid_attrs = %{
        "code" => "testProduct",
        "name" => "test product",
        "require_approval" => false,
        "require_docs" => false
      }

      assert {:error, %Changeset{}} = Products.create(valid_attrs)
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      created_product = product_fixture()

      update_attrs = %{
        code: "testProduct",
        name: "some updated name",
        status: "pending",
        currency: "KES",
        start_date: ~D[2024-07-13],
        end_date: ~D[2024-07-13],
        is_enabled: false,
        require_approval: true,
        require_docs: true
      }

      assert {:ok, %Product{} = product} = Products.update(created_product, update_attrs)
      assert product.code == created_product.code
      assert product.name == "some updated name"
      assert product.status == "pending"
      assert product.currency == "KES"
      assert product.start_date == ~D[2024-07-13]
      assert product.end_date == ~D[2024-07-13]
      assert product.is_enabled == false
      assert product.require_approval == true
      assert product.require_docs == true
    end

    test "update_product/2 with invalid data returns error changeset" do
      created_product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update(created_product, @invalid_attrs)
      assert {:ok, product} = Products.get(created_product.id)
      assert created_product == product
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete(product)
      assert {:error, :product_not_found} = Products.get(product.id)
    end

    test "fetch_configs/1 return with empty configurations" do
      product = product_fixture()
      %Product{} = product = Products.fetch_configs(product)
      assert product.configuration == []
    end

    test "build_configuration_map/1 return map of configs" do
      config1 = %Configuration{name: "name1", value: "value1"}
      config2 = %Configuration{name: "name2", value: "value2"}

      configs = [
        config1,
        config2
      ]

      mapped_config = Enum.into(configs, %{}, fn config -> {config.name, config} end)

      assert mapped_config == Products.build_configuration_map(configs)
    end
  end
end
