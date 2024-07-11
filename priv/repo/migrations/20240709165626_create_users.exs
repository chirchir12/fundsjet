defmodule Fundsjet.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :uuid, null: false
      add :username, :string, null: false
      add :email, :string, null: false
      add :type, :string, null: false
      add :first_name, :string
      add :last_name, :string
      add :primary_phone, :string
      add :password_hash, :string, null: false
      add :is_active, :boolean, null: false
      add :email_verified, :boolean, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:uuid])
    create unique_index(:users, [:email])
  end
end
