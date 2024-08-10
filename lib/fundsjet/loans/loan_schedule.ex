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

    # VIRTUAL
    field :total_amount, :float, virtual: true # installment_amount + penalties
    field :remaining_amount, :float, virtual: true # total_amount - total_repaid_amount
    field :repaid_amount, :float, virtual: true #current amount being repaid
    field :total_repaid_amount, :float, virtual: true #sum of repayments

    timestamps(type: :utc_datetime)
    # loan_id
    belongs_to :loan, Loan
    has_many :repayments, Fundsjet.Loans.Repayment
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
    |> Repo.preload(:repayments)
    |> Enum.map(&calc_total_loan_amount/1)
    |> Enum.map(&calc_total_repaid_amount/1)
    |> Enum.map(&cacl_remaining_amount/1)
  end

  def list(loan_id, status) when status === "active" do
    query = from lr in __MODULE__, where: lr.loan_id == ^loan_id and lr.status != "paid"

    Repo.all(query)
    |> Repo.preload(:repayments)
    |> Enum.map(&calc_total_loan_amount/1)
    |> Enum.map(&calc_total_repaid_amount/1)
    |> Enum.map(&cacl_remaining_amount/1)
    |> IO.inspect()
  end

  def list(loan_id, status) do
    query = from lr in __MODULE__, where: lr.loan_id == ^loan_id and lr.status == ^status

    Repo.all(query)
    |> Repo.preload(:repayments)
    |> Enum.map(&calc_total_loan_amount/1)
    |> Enum.map(&calc_total_repaid_amount/1)
    |> Enum.map(&cacl_remaining_amount/1)
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

  def update(schedules, params) when is_list(schedules) do
    Repo.transaction(fn ->
      attrs = %{
        status: "paid",
        paid_on: Map.get(params, "paid_on", DateTime.utc_now()),
        updated_at: DateTime.utc_now(),
        meta: params
      }

      schedules
      |> Enum.filter(fn schedule -> schedule.remaining_amount == schedule.repaid_amount  end)
      |> Enum.each(fn schedule ->
        case update_schedule(schedule, attrs) do
          {:ok, _} -> :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
    end)
  end

  def update_schedule(schedule, attrs) do
    schedule
    |> changeset(attrs)
    |> Repo.update()
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

  defp calc_total_loan_amount(%__MODULE__{} = schedule) do
    total_amount =
      Decimal.to_float(schedule.installment_amount) + Decimal.to_float(schedule.penalty_fee)

    %{schedule | total_amount: total_amount}
  end

  defp calc_total_repaid_amount(%__MODULE__{repayments: repayments} = schedule) when length(repayments) >0 do
    total_amount = repayments |> Enum.reduce(0, fn (repayment, acc) -> Decimal.to_float(repayment.amount) + acc  end)
    %{schedule | total_repaid_amount: total_amount}
  end

  defp calc_total_repaid_amount(schedule) do
    %{schedule | total_repaid_amount: 0}
  end

  defp cacl_remaining_amount(%__MODULE__{} = schedule) do
    remaining_amount = schedule.total_amount - schedule.total_repaid_amount
    %{schedule | remaining_amount: remaining_amount}
  end
end
