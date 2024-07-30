defmodule Fundsjet.CustomersTest do
  use Fundsjet.DataCase

  alias Fundsjet.Customers

  describe "customers" do
    alias Fundsjet.Customers.Customer

    import Fundsjet.CustomersFixtures

    @invalid_attrs %{
      "first_name" => nil,
      "last_name" => nil,
      "phone_number" => nil,
      "email" => nil,
      "identification_type" => nil,
      "identification_number" => nil
    }

    @valid_attrs %{
      "customer_number" => "1234",
      "first_name" => "first_name",
      "last_name" => "last_name",
      "phone_number" => "254111111111",
      # same email as abov
      "email" => "test1@mail.com",
      "identification_type" => "national_id",
      "identification_number" => "1234"
    }

    test "list/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list() == [customer]
    end

    test "get/1 returns the customer with given id" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = cus} = Customers.get(customer.id)
      assert cus == customer
    end

    test "get/1 returns error when customer is not found with given id" do
      assert {:error, :customer_not_found} = Customers.get(-1)
    end

    test "get/2 returns the customer with given uuid" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = cus} = Customers.get(:uuid, customer.uuid)
      assert cus == customer
    end

    test "get/2 returns error when customer is not found with given uuid" do
      assert {:error, :customer_not_found} = Customers.get(:uuid, Ecto.UUID.generate())
    end

    test "create/1 with valid data creates a customer" do
      assert {:ok, %Customer{} = customer} = Customers.create(@valid_attrs)
      assert customer.customer_number == "1234"
      assert customer.first_name == "first_name"
      assert customer.last_name == "last_name"
      assert customer.phone_number == "254111111111"
      assert customer.email == "test1@mail.com"
      assert customer.identification_type == "national_id"
      assert customer.identification_number == "1234"
      assert customer.uuid != nil
    end

    test "create/1 with with existing email error changeset" do
      _ = customer_fixture(%{"email" => "test1@mail.com"})

      assert {:error, %Ecto.Changeset{}} = Customers.create(@valid_attrs)
    end

    test "create/1 with with invalid email error changeset" do
      attrs = @valid_attrs |> Map.put("email", "email")
      assert {:error, %Ecto.Changeset{}} = Customers.create(attrs)
    end

    test "create/1 with with existing phone error changeset" do
      _ = customer_fixture(%{"phone_number" => "254111111111"})

      assert {:error, %Ecto.Changeset{}} = Customers.create(@valid_attrs)
    end

    test "create/1 with with invalid phone error changeset" do
      attrs = @valid_attrs |> Map.put("phone_number", "phone")
      assert {:error, %Ecto.Changeset{}} = Customers.create(attrs)

      attrs = @valid_attrs |> Map.put("phone_number", "0711111111")
      assert {:error, %Ecto.Changeset{}} = Customers.create(attrs)
    end

    test "create/1 with with existing identification number error changeset" do
      _ = customer_fixture(%{"identification_number" => "1234"})

      assert {:error, %Ecto.Changeset{}} = Customers.create(@valid_attrs)
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the customer" do
      cust = customer_fixture()

      update_attrs = %{
        customer_number: "1234567",
        first_name: "first_name",
        last_name: "updated_last_name",
        phone_number: "254222222222",
        identification_type: "passport",
        identification_number: "54321"
      }

      assert {:ok, %Customer{} = customer} = Customers.update(cust, update_attrs)
      assert customer.customer_number == "1234567"
      assert customer.first_name == "first_name"
      assert customer.last_name == "updated_last_name"
      assert customer.phone_number == "254222222222"
      assert customer.email == cust.email
      assert customer.uuid == cust.uuid
      assert customer.identification_type == "passport"
      assert customer.identification_number == "54321"
    end

    test "update/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update(customer, @invalid_attrs)
      assert {:ok, %Customer{} = cus} = Customers.get(customer.id)
      assert cus == customer
    end

    test "delete/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete(customer)
      assert {:error, :customer_not_found} = Customers.get(-1)
    end
  end
end
