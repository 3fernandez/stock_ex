defmodule StockExWeb.OrderLive.Index do
  use StockExWeb, :live_view

  alias StockEx.Stocks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :orders, Stocks.list_orders())}
  end
end
