defmodule Fundsjet.Repo.Migrations.CreateConfiguration do
  use Ecto.Migration

  def change do
    create table(:configuration) do
      add :product_id, references(:products), null: true
      add :name, :string, null: false
      add :value, :string, null: false
      add :description, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:configuration, [:name, :product_id])
  end
end
