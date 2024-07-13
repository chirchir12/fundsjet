defmodule Fundsjet.ProductsTest do
  use Fundsjet.DataCase

  alias Fundsjet.Products

  describe "products" do
    alias Fundsjet.Products.Producct

    import Fundsjet.ProductsFixtures

    @invalid_attrs %{
      code: nil,
      name: nil,
      status: nil,
      currency: nil,
      start_date: nil,
      end_date: nil,
      is_enabled: nil,
      updated_by: nil,
      created_by: nil,
      require_approval: nil,
      require_docs: nil
    }

    test "list_products/0 returns all products" do
      producct = producct_fixture()
      assert Products.list_products() == [producct]
    end

    test "get_producct!/1 returns the producct with given id" do
      producct = producct_fixture()
      assert Products.get_producct!(producct.id) == producct
    end

    test "create_producct/1 with valid data creates a producct" do
      valid_attrs = %{
        code: "some code",
        name: "some name",
        status: "some status",
        currency: "some currency",
        start_date: ~D[2024-07-12],
        end_date: ~D[2024-07-12],
        is_enabled: true,
        updated_by: 42,
        created_by: 42,
        require_approval: true,
        require_docs: true
      }

      assert {:ok, %Producct{} = producct} = Products.create_producct(valid_attrs)
      assert producct.code == "some code"
      assert producct.name == "some name"
      assert producct.status == "some status"
      assert producct.currency == "some currency"
      assert producct.start_date == ~D[2024-07-12]
      assert producct.end_date == ~D[2024-07-12]
      assert producct.is_enabled == true
      assert producct.updated_by == 42
      assert producct.created_by == 42
      assert producct.require_approval == true
      assert producct.require_docs == true
    end

    test "create_producct/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_producct(@invalid_attrs)
    end

    test "update_producct/2 with valid data updates the producct" do
      producct = producct_fixture()

      update_attrs = %{
        code: "some updated code",
        name: "some updated name",
        status: "some updated status",
        currency: "some updated currency",
        start_date: ~D[2024-07-13],
        end_date: ~D[2024-07-13],
        is_enabled: false,
        updated_by: 43,
        created_by: 43,
        require_approval: false,
        require_docs: false
      }

      assert {:ok, %Producct{} = producct} = Products.update_producct(producct, update_attrs)
      assert producct.code == "some updated code"
      assert producct.name == "some updated name"
      assert producct.status == "some updated status"
      assert producct.currency == "some updated currency"
      assert producct.start_date == ~D[2024-07-13]
      assert producct.end_date == ~D[2024-07-13]
      assert producct.is_enabled == false
      assert producct.updated_by == 43
      assert producct.created_by == 43
      assert producct.require_approval == false
      assert producct.require_docs == false
    end

    test "update_producct/2 with invalid data returns error changeset" do
      producct = producct_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_producct(producct, @invalid_attrs)
      assert producct == Products.get_producct!(producct.id)
    end

    test "delete_producct/1 deletes the producct" do
      producct = producct_fixture()
      assert {:ok, %Producct{}} = Products.delete_producct(producct)
      assert_raise Ecto.NoResultsError, fn -> Products.get_producct!(producct.id) end
    end

    test "change_producct/1 returns a producct changeset" do
      producct = producct_fixture()
      assert %Ecto.Changeset{} = Products.change_producct(producct)
    end
  end
end
