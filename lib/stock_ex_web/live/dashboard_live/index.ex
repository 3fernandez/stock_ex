defmodule StockExWeb.DashboardLive.Index do
  use StockExWeb, :live_view

  alias StockEx.Stocks

  @impl true
  def mount(_params, _session, socket) do
    stream =
      socket
      |> stream_configure(:stocks, dom_id: &"stock-#{&1.symbol}")
      |> stream(:stocks, Stocks.list_stocks())

    {:ok, stream}
  end

  @impl true
  def handle_event("buy", order_params, socket) do
    order_params = Map.put(order_params, "quantity", socket.assigns[:order_quantity])

    IO.inspect(order_params, label: "The Order Params: ")

    case Stocks.create_order(socket.assigns[:current_user], order_params) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully")
         |> push_patch(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "There was an error while placing your order.")
         |> assign(changeset: changeset)}
    end
  end

  def handle_event("update_quantity", %{"quantity" => quantity}, socket) do
    {:noreply, assign(socket, :order_quantity, String.to_integer(quantity))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Show Available Stocks")
    |> assign(:order, nil)
  end
end
