defmodule Fundsjet.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :code, :string, null: false
      add :description, :string, null: false
      add :currency, :string
      add :start_date, :date
      add :end_date, :date
      add :status, :string, null: false
      add :is_enabled, :boolean, default: false, null: false
      add :updated_by, :integer
      add :created_by, :integer
      add :require_approval, :boolean, default: false, null: false
      add :require_docs, :boolean, default: false, null: false
      add :automatic_disbursement, :boolean, default: false, null: false
      add :approval_meta, :map
      add :documents_meta, :map
      add :additional_info, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:code])
  end
end
