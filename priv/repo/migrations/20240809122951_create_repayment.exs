defmodule Fundsjet.Repo.Migrations.CreateRepayment do
  use Ecto.Migration

  def change do
    create table(:loan_repayments) do
      add :loan_id, references(:loans), null: false
      add :loan_schedule_id, references(:loan_schedules), null: false
      add :amount, :decimal, null: false
      add :paid_on, :utc_datetime, null: false
      add :meta, :map, null: false
      timestamps(type: :utc_datetime)
    end

    create index(:loan_repayments, [:loan_id, :loan_schedule_id ])
  end
end
