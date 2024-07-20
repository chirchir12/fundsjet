defmodule Fundsjet.Repo.Migrations.CreateLoanApprovers do
  use Ecto.Migration

  def change do
    create table(:loan_approvers) do
      add :loan_id, references(:loans), null: false
      add :staff_id, references(:users), null: false
      add :status, :string, null: false
      add :priority, :integer
      add :comment, :text
      timestamps(type: :utc_datetime)
    end

    create unique_index(:loan_approvers, [:loan_id, :staff_id])
  end
end
