defmodule Fundsjet.CustomersTest do
  use Fundsjet.DataCase

  alias Fundsjet.Customers

  describe "customers" do
    alias Fundsjet.Customers.Customer

    import Fundsjet.CustomersFixtures

    @invalid_attrs %{
      user_id: nil,
      customer_number: nil,
      first_name: nil,
      last_name: nil,
      phone_number: nil,
      email: nil,
      identification_type: nil,
      identification_number: nil,
      profile_pic: nil
    }

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Customers.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      valid_attrs = %{
        user_id: 42,
        customer_number: "some customer_number",
        first_name: "some first_name",
        last_name: "some last_name",
        phone_number: "some phone_number",
        email: "some email",
        identification_type: "some identification_type",
        identification_number: "some identification_number",
        profile_pic: "some profile_pic"
      }

      assert {:ok, %Customer{} = customer} = Customers.create_customer(valid_attrs)
      assert customer.user_id == 42
      assert customer.customer_number == "some customer_number"
      assert customer.first_name == "some first_name"
      assert customer.last_name == "some last_name"
      assert customer.phone_number == "some phone_number"
      assert customer.email == "some email"
      assert customer.identification_type == "some identification_type"
      assert customer.identification_number == "some identification_number"
      assert customer.profile_pic == "some profile_pic"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()

      update_attrs = %{
        user_id: 43,
        customer_number: "some updated customer_number",
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        phone_number: "some updated phone_number",
        email: "some updated email",
        identification_type: "some updated identification_type",
        identification_number: "some updated identification_number",
        profile_pic: "some updated profile_pic"
      }

      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, update_attrs)
      assert customer.user_id == 43
      assert customer.customer_number == "some updated customer_number"
      assert customer.first_name == "some updated first_name"
      assert customer.last_name == "some updated last_name"
      assert customer.phone_number == "some updated phone_number"
      assert customer.email == "some updated email"
      assert customer.identification_type == "some updated identification_type"
      assert customer.identification_number == "some updated identification_number"
      assert customer.profile_pic == "some updated profile_pic"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, @invalid_attrs)
      assert customer == Customers.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end
end
