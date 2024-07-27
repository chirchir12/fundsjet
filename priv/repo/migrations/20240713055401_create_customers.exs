defmodule Fundsjet.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :uuid, :uuid, null: false
      add :user_id, references(:users), null: true
      add :customer_number, :string
      add :first_name, :string
      add :last_name, :string
      add :phone_number, :string
      add :email, :string
      add :is_enabled, :boolean, null: false
      add :identification_type, :string
      add :identification_number, :string
      add :profile_pic, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:customers, [:customer_number])
    create unique_index(:customers, [:uuid])
    create unique_index(:customers, [:phone_number])
    create unique_index(:customers, [:email])
    create unique_index(:customers, [:identification_number])
  end
end
