defmodule Fundsjet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FundsjetWeb.Telemetry,
      Fundsjet.Repo,
      {DNSCluster, query: Application.get_env(:fundsjet, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Fundsjet.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Fundsjet.Finch},
      # Start a worker by calling: Fundsjet.Worker.start_link(arg)
      # {Fundsjet.Worker, arg},
      # Start to serve requests, typically the last entry
      FundsjetWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fundsjet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FundsjetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
