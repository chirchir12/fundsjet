defmodule Fundsjet.Repo.Migrations.CreateLoanRepaymentSchedule do
  use Ecto.Migration

  def change do
    create table(:loan_repayment_schedule) do
      add :loan_id, references(:loans), null: false
      add :installment_date, :date, null: false
      add :installment_amount, :decimal, null: false
      add :penalty_fee, :decimal, null: false, default: 0
      add :status, :string, null: false
      add :paid_on, :utc_datetime
      add :next_penalty_date, :date, null: true
      add :penalty_count, :integer
      add :meta, :map
      timestamps(type: :utc_datetime)
    end
  end
end
