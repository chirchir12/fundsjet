defmodule Fundsjet.Loans.LoanSchedule do
  alias Fundsjet.Repo
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset
  alias Fundsjet.Loans.Loan
  alias Fundsjet.Products.Product

  @allowed_status [
    "pending",
    "paid",
    "late"
  ]

  @permitted [
    :loan_id,
    :installment_date,
    :installment_amount,
    :penalty_fee,
    :status,
    :paid_on,
    :next_penalty_date,
    :penalty_count,
    :meta
  ]

  @required [
    :loan_id,
    :installment_amount,
    :installment_date,
    :status
  ]

  schema "loan_schedules" do
    field :installment_date, :date
    field :installment_amount, :decimal
    field :penalty_fee, :decimal
    field :status, :string
    field :paid_on, :utc_datetime
    field :next_penalty_date, :date
    field :penalty_count, :integer
    field :meta, :map

    timestamps(type: :utc_datetime)
    # loan_id
    belongs_to :loan, Loan
    has_many :schedules, Fundsjet.Loans.Repayment

  end

  @doc false
  def changeset(repayment, attrs) do
    repayment
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> validate_inclusion(:status, @allowed_status)
  end

  def list(loan_id) do
    query = from lr in __MODULE__, where: lr.loan_id == ^loan_id
    Repo.all(query)
  end

  def add(product, loan) do
    Repo.transaction(fn ->
      generate_schedules(product, loan)
      |> Enum.each(fn schedule ->
        changeset =
          changeset(%__MODULE__{}, Map.from_struct(schedule))

        case Repo.insert(changeset) do
          {:ok, _} -> :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
    end)
  end



  defp generate_schedules(%Product{} = product, %Loan{} = loan) do
    1..product.loan_term
    |> Enum.map(fn term ->
      %__MODULE__{
        loan_id: loan.id,
        status: "pending",
        installment_amount:
          (Decimal.to_float(loan.amount) + Decimal.to_float(loan.commission)) / product.loan_term,
        installment_date: Date.add(loan.disbursed_on, term * product.loan_duration)
      }
    end)
  end
end
