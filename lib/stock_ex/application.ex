defmodule StockEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StockExWeb.Telemetry,
      StockEx.Repo,
      {DNSCluster, query: Application.get_env(:stock_ex, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StockEx.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: StockEx.Finch},
      # Start a worker by calling: StockEx.Worker.start_link(arg)
      # {StockEx.Worker, arg},
      # Start to serve requests, typically the last entry
      StockExWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StockExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
