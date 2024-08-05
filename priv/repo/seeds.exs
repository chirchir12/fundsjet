# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fundsjet.Repo.insert!(%Fundsjet.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

config = Application.get_env(:fundsjet, Fundsjet.Products)

# seed loan product if it is enabled
if Keyword.get(config, :loan_product) and !Fundsjet.Products.exists?("personal_loan") do
  {:ok, %Fundsjet.Products.Product{id: product_id}} =
    %{
      code: "personal_loan",
      name: "Personal Loan",
      description: "Test loan personal loan",
      currency: "KES",
      is_enabled: true,
      require_approval: true,
      require_docs: true
    }
    |> Fundsjet.Products.create()

  [
    %{
      name: "loan_duration",
      value: "30",
      description: "loan Duration in days",
      product_id: product_id
    },
    %{
      name: "repayment_term",
      value: "1",
      description: "Repayment is repaid after maturity",
      product_id: product_id
    },
    %{
      name: "loan_comission",
      value: "10",
      description: "Loan commission",
      product_id: product_id
    },
    %{
      name: "loan_term",
      value: "1",
      description: "Loan Term for Repayment schedul",
      product_id: product_id
    },
    %{
      name: "commission_type",
      value: "percent",
      description: "Loan commission type",
      product_id: product_id
    },
    %{
      name: "loan_penalty",
      value: "50",
      description: "Loan Penalty",
      product_id: product_id
    },
    %{
      name: "penalty_type",
      value: "flat",
      description: "Loan Penalty type",
      product_id: product_id
    },
    %{
      name: "penalty_duration",
      value: "60",
      description: "maximum days to apply penalty",
      product_id: product_id
    },
    %{
      name: "penalty_after",
      value: "5",
      description: "number of days to apply penalty after last penalty is applied",
      product_id: product_id
    }
  ]
  |> Fundsjet.Products.Configurations.create()
end
