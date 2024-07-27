defmodule Fundsjet.Repo.Migrations.CreateLoanReviewers do
  use Ecto.Migration

  def change do
    create table(:loan_reviewers) do
      add :loan_id, references(:loans), null: false
      add :staff_id, references(:users), null: false
      add :status, :string, null: false
      add :priority, :integer
      add :comment, :text
      timestamps(type: :utc_datetime)
    end

    create unique_index(:loan_reviewers, [:loan_id, :staff_id])
  end
end
