defmodule StockExWeb.PortfolioLive.Index do
  use StockExWeb, :live_view

  alias StockEx.Stocks

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]

    {:ok, assign(socket, :portfolio_items, Stocks.list_portfolio(user.id))}
  end
end
