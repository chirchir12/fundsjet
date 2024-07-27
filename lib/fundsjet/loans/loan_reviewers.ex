defmodule Fundsjet.Loans.LoanReviewers do
  @moduledoc false
  alias Fundsjet.Repo
  import Ecto.Query, warn: false
  alias Fundsjet.Loans.{Loan, LoanReview}
  alias Fundsjet.Identity.User

  def add_reviewer(%Loan{id: loan_id}, %User{id: staff_id}, priority \\ 1) do
    attrs = %{
      loan_id: loan_id,
      staff_id: staff_id,
      status: "pending",
      priority: priority
    }

    %LoanReview{}
    |> LoanReview.changeset(attrs)
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
    query = from a in LoanReview, where: a.loan_id == ^loan_id
    Repo.all(query)
  end

  def get_review(loan_id, staff_id) do
    query = from a in LoanReview, where: a.staff_id == ^staff_id and a.loan_id == ^loan_id

    case Repo.one(query) do
      nil ->
        {:error, :review_not_found}

      reviewer ->
        {:ok, reviewer}
    end
  end

  def add_review(%LoanReview{} = review, params) do
    review
    |> LoanReview.add_review_changeset(params)
    |> Repo.update()
  end

  def is_in_review?(loan_id) do
    query = from a in LoanReview, where: a.loan_id == ^loan_id and a.status == "pending"

    case Repo.exists?(query) do
      true ->
        {:ok, true}

      false ->
        {:ok, false}
    end
  end
end
