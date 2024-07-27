defmodule Fundsjet.Repo.Migrations.CreateLoanReviews do
  use Ecto.Migration

  def change do
    create table(:loan_reviews) do
      add :loan_id, references(:loans), null: false
      add :staff_id, references(:users), null: false
      add :status, :string, null: false
      add :priority, :integer
      add :comment, :text
      timestamps(type: :utc_datetime)
    end

    create unique_index(:loan_reviews, [:loan_id, :staff_id])
  end
end
