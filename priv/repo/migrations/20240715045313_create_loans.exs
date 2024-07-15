defmodule Fundsjet.Repo.Migrations.CreateLoans do
  use Ecto.Migration

  def change do
    create table(:loans) do
      add :customer_id, references(:customers), null: false
      add :product_id, references(:products), null: false
      add :amount, :decimal, null: false
      add :commission, :decimal, null: false
      add :maturity_date, :date, null: false
      add :status, :string, null: false
      add :uuid, :uuid, null: false
      add :duration, :integer, null: false
      add :term, :integer, null: false
      add :disbursed_on, :date, null: false
      add :closed_on, :date
      add :created_by, :integer, null: false
      add :updated_by, :integer
      add :meta, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:loans, [:uuid])
  end
end
