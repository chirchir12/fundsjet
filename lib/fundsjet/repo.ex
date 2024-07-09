defmodule Fundsjet.Repo do
  use Ecto.Repo,
    otp_app: :fundsjet,
    adapter: Ecto.Adapters.Postgres
end
