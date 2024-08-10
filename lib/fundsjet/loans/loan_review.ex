defmodule Fundsjet.Loans.LoanReview do
  alias Fundsjet.Repo
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  alias Fundsjet.Loans.Loan
  alias Fundsjet.Identity.User

  @allowed_status [
    "pending",
    "approved",
    "rejected"
  ]

  @permitted [
    :staff_id,
    :loan_id,
    :priority,
    :status,
    :comment
  ]

  @required [
    :staff_id,
    :loan_id,
    :priority,
    :status
  ]

  schema "loan_reviews" do
    field :priority, :integer
    field :status, :string
    field :comment, :string
    timestamps(type: :utc_datetime)
    # loan_id
    belongs_to :loan, Loan
    # staff_id
    belongs_to :staff, User
  end

  @doc false
  def changeset(approvers, attrs) do
    approvers
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint([:loan_id, :staff_id])
    |> validate_inclusion(:status, @allowed_status)
  end

  def add_review_changeset(%__MODULE__{} = review, attrs) do
    review
    |> cast(attrs, [:status, :comment])
    |> validate_required([:status, :comment])
    |> validate_inclusion(:status, @allowed_status)
  end

  def add_reviewer(%Loan{id: loan_id}, %User{id: staff_id}, priority \\ 1) do
    attrs = %{
      loan_id: loan_id,
      staff_id: staff_id,
      status: "pending",
      priority: priority
    }

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, reviewer} ->
        {:ok, reviewer}

      {:error, _changeset} ->
        {:ok, reviewer} = get_review(loan_id, staff_id)
        {:ok, reviewer}
    end
  end

  def get_reviews(loan_id) do
    query = from a in __MODULE__, where: a.loan_id == ^loan_id
    Repo.all(query)
  end

  def get_review(loan_id, staff_id) do
    query = from a in __MODULE__, where: a.staff_id == ^staff_id and a.loan_id == ^loan_id

    case Repo.one(query) do
      nil ->
        {:error, :review_not_found}

      reviewer ->
        {:ok, reviewer}
    end
  end

  def add_review(%__MODULE__{} = review, params) do
    review
    |> add_review_changeset(params)
    |> Repo.update()
  end

  def is_in_review?(loan_id) do
    query = from a in __MODULE__, where: a.loan_id == ^loan_id and a.status == "pending"

    case Repo.exists?(query) do
      true ->
        {:ok, true}

      false ->
        {:ok, false}
    end
  end
end
