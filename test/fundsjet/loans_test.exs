defmodule Fundsjet.LoansTest do
  alias Fundsjet.Loans.LoanSchedule
  alias Fundsjet.Loans.FilterLoan
  # alias Fundsjet.Products.Product
  use Fundsjet.DataCase

  alias Fundsjet.Loans
  alias Fundsjet.Loans.{Loan, LoanReview}

  alias Fundsjet.Repo

  import Fundsjet.LoansFixtures

  describe "loans" do
    setup [:create_product, :create_customer, :create_staff]

    @invalid_attrs %{
      "customer_id" => nil,
      "amount" => nil,
      "created_by" => nil
    }

    test "list/0 return list of loans", %{product: product, customer: customer} do
      assert Loans.list() == []

      loan = loan_fixture(product, customer)
      assert Loans.list() == [loan]
    end

    test "list/1 return loan when filtered with customer_id and status=active", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: customer.id, status: "active"}) == [loan]
    end

    test "list/1 return loan when filtered with customer_id and status=pending", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: customer.id, status: "pending"}) == [loan]
    end

    test "list/1 return loan when filtered with customer_id only", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: customer.id}) == [loan]
    end

    test "list/1 return loan when filtered values are null", %{
      product: product,
      customer: customer
    } do
      loan = loan_fixture(product, customer)
      assert Loans.list(%FilterLoan{customer_id: nil}) == [loan]
    end

    test "check_active_loan/1 check if customer has active loan and return error", %{
      product: product,
      customer: customer
    } do
      _loan = loan_fixture(product, customer)
      assert {:error, :customer_has_active_loan} = Loans.check_active_loan(customer.id)
    end

    test "check_active_loan/1 return error when customer id is nil" do
      assert {:error, :error_checking_active_loans} = Loans.check_active_loan(nil)
    end

    test "get/1 return loan valid loan is is passed", %{
      product: product,
      customer: customer
    } do
      created_loan = loan_fixture(product, customer)
      assert {:ok, %Loan{} = loan} = Loans.get(created_loan.id)
      assert created_loan == loan
    end

    test "create_loan/3 with valid data creates a loan that require approval process", %{
      product: product,
      customer: customer
    } do
      loan_amount = 1000
      commission_value = Decimal.to_float(product.loan_comission)

      commission =
        cond do
          product.commission_type == "flat" ->
            commission_value

          true ->
            commission_value / 100 * loan_amount
        end

      assert {:ok, %Loan{} = loan} =
               Loans.create_loan(product, customer, %{
                 "amount" => loan_amount,
                 "created_by" => customer.id,
                 "customer_id" => customer.id
               })

      loan_with_schedule = Repo.preload(loan, :loan_schedules)
      assert length(loan_with_schedule.loan_schedules) == 0

      assert loan.meta == nil
      assert loan.status == "pending"
      assert loan.term == product.loan_term
      assert loan.uuid != nil
      assert loan.customer_id == customer.id
      assert loan.product_id == product.id
      assert loan.amount == Decimal.new(loan_amount)
      assert loan.commission == Decimal.from_float(commission)
      assert loan.maturity_date == nil
      assert loan.duration == product.loan_duration
      assert loan.disbursed_on == nil
      assert loan.closed_on == nil
    end

    test "create_loan/3 with valid data creates a loan that does not require approval process and is not automatically disbursed",
         %{
           customer: customer
         } do
      product =
        create_loan_product_fixture(%{
          code: "testLoanProduct",
          require_approval: false,
          automatic_disbursement: false,
          commission_type: "flat"
        })

      loan_amount = 1000

      assert {:ok, %Loan{} = loan} =
               Loans.create_loan(product, customer, %{
                 "amount" => loan_amount,
                 "created_by" => customer.id,
                 "customer_id" => customer.id
               })

      loan_with_schedule = Repo.preload(loan, :loan_schedules)
      assert length(loan_with_schedule.loan_schedules) == 0

      assert loan.status == "approved"
      assert loan.term == product.loan_term
      assert loan.uuid != nil
      assert loan.customer_id == customer.id
      assert loan.product_id == product.id
      assert loan.amount == Decimal.new(loan_amount)

      assert loan.commission ==
               (Decimal.to_float(product.loan_comission) / 1.0) |> Decimal.from_float()

      assert loan.maturity_date == nil
      assert loan.duration == product.loan_duration
      assert loan.disbursed_on == nil
      assert loan.closed_on == nil
    end

    test "create_loan/3 with valid data creates a loan that does not require approval process and is automatically disbursed",
         %{
           customer: customer
         } do
      product =
        create_loan_product_fixture(%{
          code: "testLoanProduct",
          require_approval: false,
          automatic_disbursement: true,
          loan_term: 3
        })

      loan_amount = 1000
      commission_value = Decimal.to_float(product.loan_comission)
      today = Date.utc_today()

      commission =
        cond do
          product.commission_type === "flat" ->
            commission_value

          true ->
            commission_value / 100 * loan_amount
        end

      assert {:ok, %Loan{} = loan} =
               Loans.create_loan(product, customer, %{
                 "amount" => loan_amount,
                 "created_by" => customer.id,
                 "customer_id" => customer.id,
                 "disbursed_on" => today
               })

      loan_with_schedule = Repo.preload(loan, :loan_schedules)
      assert length(loan_with_schedule.loan_schedules) == product.loan_term

      assert loan.meta == nil
      assert loan.status == "disbursed"
      assert loan.term == product.loan_term
      assert loan.uuid != nil
      assert loan.customer_id == customer.id
      assert loan.product_id == product.id
      assert loan.amount == Decimal.new(loan_amount)
      assert loan.commission == Decimal.from_float(commission)
      assert loan.maturity_date == Date.add(today, product.loan_duration * product.loan_term)
      assert loan.duration == product.loan_duration
      assert loan.disbursed_on == today
      assert loan.closed_on == nil

      total_amount_due = Decimal.to_float(loan.amount) + Decimal.to_float(loan.commission)

      # repayment schedule
      Stream.with_index(loan_with_schedule.loan_schedules, 1)
      |> Enum.each(fn {%LoanSchedule{} = schedule, term} ->
        assert Decimal.to_float(schedule.installment_amount) ===
                 total_amount_due / product.loan_term

        assert schedule.installment_date === Date.add(today, term * product.loan_duration)
        assert schedule.status == "pending"
        assert schedule.penalty_fee == Decimal.new(0)
      end)
    end

    test "create_loan/3 with invalid data returns error changeset", %{
      product: product,
      customer: customer
    } do
      assert {:error, %Ecto.Changeset{}} = Loans.create_loan(product, customer, @invalid_attrs)
    end

    test "create_loan/3 throws error when customer has an active loan", %{
      product: product,
      customer: customer
    } do
      _loan = loan_fixture(product, customer)

      assert {:error, :customer_has_active_loan} =
               Loans.create_loan(product, customer, %{
                 "amount" => 100,
                 "created_by" => customer.id,
                 "customer_id" => customer.id
               })
    end

    test "approve_loan/2  approves loan that has been reviewed", %{
      product: product,
      customer: customer,
      staff: staff
    } do
      # ensure the product require approval
      assert product.require_approval == true

      review_data = %{
        "status" => "approved",
        "comment" => "customer can take loan"
      }

      approval_data = %{
        "status" => "approved",
        "updated_by" => staff.id,
        "updated_at" => DateTime.utc_now()
      }

      # create loan
      loan = loan_fixture(product, customer)

      # create reviewer
      assert {:ok, %LoanReview{} = review} = Loans.add_reviewer(loan, staff, 1)
      assert review.status == "pending"

      #  ensure loan cannot be approved unless reviewed
      assert {:error, :error_approving_loan} = Loans.approve_loan(loan, review_data)

      # review loan

      assert {:ok, %LoanReview{} = review} = Loans.add_review(loan, review, review_data)

      assert review.status == "approved"

      assert {:ok, %Loan{status: "in_review"} = loan} = Loans.get(loan.id)

      assert {:ok, %Loan{status: "approved"}} = Loans.approve_loan(loan, approval_data)
    end

    test "disburse/2  disburse only loans that have been approved", %{
      product: product,
      customer: customer,
      staff: staff
    } do
      # ensure the product require approval
      assert product.require_approval == true
      today = Date.utc_today()

      review_data = %{
        "status" => "approved",
        "comment" => "customer can take loan"
      }

      approval_data = %{
        "status" => "approved",
        "updated_by" => staff.id,
        "updated_at" => DateTime.utc_now()
      }

      # create loan
      loan = loan_fixture(product, customer)

      assert {:error, :loan_has_not_been_approved} = Loans.disburse_loan(loan, Date.utc_today())

      # create reviewer
      assert {:ok, %LoanReview{} = review} = Loans.add_reviewer(loan, staff, 1)

      # review loan
      assert {:ok, %LoanReview{} = review} = Loans.add_review(loan, review, review_data)

      assert review.status == "approved"

      assert {:ok, %Loan{status: "in_review"} = loan} = Loans.get(loan.id)

      assert {:ok, %Loan{status: "approved"} = loan} = Loans.approve_loan(loan, approval_data)

      assert {:ok, %Loan{status: "disbursed"} = loan} = Loans.disburse_loan(loan, today)

      assert {:error, :loan_has_been_disbursed} = Loans.disburse_loan(loan, today)

      loan_with_schedule = Repo.preload(loan, :loan_schedules)
      assert length(loan_with_schedule.loan_schedules) == product.loan_term

      assert loan.maturity_date == Date.add(today, product.loan_duration)

      # repayment schedule
      Stream.with_index(loan_with_schedule.loan_schedules, 1)
      |> Enum.each(fn {%LoanSchedule{} = schedule, term} ->
        assert schedule.installment_date === Date.add(today, term * product.loan_duration)
        assert schedule.status == "pending"
        assert schedule.penalty_fee == Decimal.new(0)
      end)
    end

    test "repay_loan/2 fully repay loan that is is either late or disbursed if full amount is passed", %{
      customer: customer,
      staff: staff
    } do
      product =
        create_loan_product_fixture(%{
          code: "testLoanProduct",
          require_approval: true,
          loan_term: 3
        })
      today = Date.utc_today()

      review_data = %{
        "status" => "approved",
        "comment" => "customer can take loan"
      }

      approval_data = %{
        "status" => "approved",
        "updated_by" => staff.id,
        "updated_at" => DateTime.utc_now()
      }



      # create loan
      loan = loan_fixture(product, customer)


      # create reviewer
      assert {:ok, %LoanReview{} = review} = Loans.add_reviewer(loan, staff, 1)

      # review loan
      assert {:ok, %LoanReview{} } = Loans.add_review(loan, review, review_data)

      assert {:ok, %Loan{status: "in_review"} = loan} = Loans.get(loan.id)

      # approve loan
      assert {:ok, %Loan{status: "approved"} = loan} = Loans.approve_loan(loan, approval_data)

      # disburse loan
      assert {:ok, %Loan{status: "disbursed"} = loan} = Loans.disburse_loan(loan, today)

      schedules = LoanSchedule.list(loan.id, "active")
      unpaid_amount = schedules |> Enum.reduce(0, fn (schedule, acc) -> schedule.remaining_amount + acc   end)

      repayment_data = %{
        "amount" => unpaid_amount,
        "ref_id" => "ref_id",
      }

      assert {:ok, %Loan{status: "paid"}} = Loans.repay_loan(loan, repayment_data)
      schedules = LoanSchedule.list(loan.id, "active")
      assert length(schedules) == 0

    end

    test "repay_loan/2 partially repay loan that is is either late or disbursed", %{
      customer: customer,
      staff: staff
    } do
      product =
        create_loan_product_fixture(%{
          code: "testLoanProduct",
          require_approval: true,
          loan_term: 3
        })
      today = Date.utc_today()

      review_data = %{
        "status" => "approved",
        "comment" => "customer can take loan"
      }

      approval_data = %{
        "status" => "approved",
        "updated_by" => staff.id,
        "updated_at" => DateTime.utc_now()
      }



      # create loan
      loan = loan_fixture(product, customer)


      # create reviewer
      assert {:ok, %LoanReview{} = review} = Loans.add_reviewer(loan, staff, 1)

      # review loan
      assert {:ok, %LoanReview{} } = Loans.add_review(loan, review, review_data)

      assert {:ok, %Loan{status: "in_review"} = loan} = Loans.get(loan.id)

      # approve loan
      assert {:ok, %Loan{status: "approved"} = loan} = Loans.approve_loan(loan, approval_data)

      # disburse loan
      assert {:ok, %Loan{status: "disbursed"} = loan} = Loans.disburse_loan(loan, today)

      schedules = LoanSchedule.list(loan.id, "active")
      unpaid_amount = schedules |> Enum.reduce(0, fn (schedule, acc) -> schedule.remaining_amount + acc   end)
      amount_to_pay = unpaid_amount / 3

      repayment_data = %{
        "amount" => amount_to_pay,
        "ref_id" => "ref_id",
      }


      # first payment
      assert {:ok, %Loan{status: "partially_repaid"}} = Loans.repay_loan(loan, repayment_data)
      schedules = LoanSchedule.list(loan.id, "active")
      assert length(schedules) === 2

      # second payment
      assert {:ok, %Loan{status: "partially_repaid"}} = Loans.repay_loan(loan, repayment_data)
      schedules = LoanSchedule.list(loan.id, "active")
      assert length(schedules) === 1

      # third payment
      assert {:ok, %Loan{status: "paid"}} = Loans.repay_loan(loan, repayment_data)
      schedules = LoanSchedule.list(loan.id, "active")
      assert length(schedules) === 0


    end

    test "create_loan/3 throws error when customer is disabled", %{
      product: product,
      customer: customer
    } do
      customer = %{customer | is_enabled: false}

      assert {:error, :customer_is_disabled} =
               Loans.create_loan(product, customer, %{
                 "amount" => 100,
                 "created_by" => customer.id,
                 "customer_id" => customer.id
               })
    end
  end

  defp create_product(_) do
    product = create_loan_product_fixture()
    %{product: product}
  end

  def create_staff(_) do
    staff = Fundsjet.Identity.UsersFixtures.create_user_fixture()
    %{staff: staff}
  end

  defp create_customer(_) do
    customer = Fundsjet.CustomersFixtures.customer_fixture()
    %{customer: customer}
  end
end
