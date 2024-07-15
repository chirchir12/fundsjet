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
if Keyword.get(config, :loan_product) and !Fundsjet.Products.product_exists?("loanProduct") do
  {:ok, %Fundsjet.Products.Product{id: product_id}} =
    %{
      code: "loanProduct",
      name: "loan product",
      status: "approved",
      # todo get from env
      currency: "KES",
      is_enabled: true,
      require_approval: false,
      require_docs: false
    }
    |> Fundsjet.Products.create_product()

  [
    %{
      name: "loanDuration",
      value: "30",
      description: "loan Duration in days",
      product_id: product_id
    },
    %{
      name: "repaymentTerm",
      value: "1",
      description: "Repayment is repaid after maturity",
      product_id: product_id
    },
    %{
      name: "loanComission",
      value: "10",
      description: "Loan commission",
      product_id: product_id
    },
    %{
      name: "commissionType",
      value: "percent",
      description: "Loan commission type",
      product_id: product_id
    },
    %{
      name: "loanPenalty",
      value: "50",
      description: "Loan Penalty",
      product_id: product_id
    },
    %{
      name: "penaltyType",
      value: "flat",
      description: "Loan Penalty type",
      product_id: product_id
    },
    %{
      name: "penaltyDuration",
      value: "60",
      description: "maximum days to apply penalty",
      product_id: product_id
    },
    %{
      name: "penaltyAfter",
      value: "5",
      description: "number of days to apply penalty after last penalty is applied",
      product_id: product_id
    }
  ]
  |> Fundsjet.Products.Cofigurations.create_configurations()
end
