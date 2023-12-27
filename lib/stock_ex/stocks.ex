defmodule StockEx.Stocks do
  @moduledoc """
  The Stocks context.
  """

  import Ecto.Query, warn: false

  alias StockEx.Repo
  alias StockEx.Stocks.StockStruct
  alias StockEx.Stocks.Order
  alias StockEx.Stocks.TreasuryApiWrapper, as: Client

  @spec list_stocks :: [StockStruct.t()] | []
  def list_stocks do
    case Client.get_symbol_info() do
      {:ok, response} -> build_stocks_list(response)
      {:error, _reason} -> []
    end
  end

  defp build_stocks_list(response) do
    response
    |> List.wrap()
    |> Enum.map(&convert_stock/1)
  end

  defp convert_stock(stock) do
    stock
    |> Map.put("price", to_integer(stock["price"]))
    |> StockStruct.new()
  end

  @spec list_orders :: [Order.t()] | []
  def list_orders do
    Repo.all(Order)
  end

  @spec list_portfolio(integer(), String.t(), String.t()) :: [map()] | []
  def list_portfolio(user_id, type \\ "buy", symbol \\ "VTI") do
    query =
      from(order in Order,
        where:
          order.type == ^type and order.ticker_symbol == ^symbol and order.user_id == ^user_id
      )

    case Repo.all(query) do
      [] -> []
      orders -> build_portfolio_list(orders)
    end
  end

  defp build_portfolio_list(orders) do
    result =
      Enum.reduce(orders, %{}, fn order, acc ->
        ticker_symbol = order.ticker_symbol
        total_invested = order.unit_price * order.shares_quantity
        shares_quantity = order.shares_quantity

        Map.update(
          acc,
          ticker_symbol,
          %{total_invested: total_invested, shares_quantity: shares_quantity},
          fn existing ->
            %{
              total_invested: existing.total_invested + total_invested,
              shares_quantity: existing.shares_quantity + shares_quantity
            }
          end
        )
      end)

    Enum.map(result, fn {ticker_symbol, values} ->
      stock_last_price = to_integer(get_stock_last_price())
      shares_valuation = calc_shares_valuation(values.shares_quantity, stock_last_price)
      avg_price = calc_avg_price(values.total_invested, values.shares_quantity)

      %{
        ticker_symbol: ticker_symbol,
        shares_valuation: shares_valuation,
        total_shares_quantity: values.shares_quantity,
        avg_price: to_integer(avg_price),
        last_price: stock_last_price
      }
    end)
  end

  defp calc_avg_price(purchase_price, total_shares), do: purchase_price / (total_shares * 100)
  defp calc_shares_valuation(total_shares, stock_last_price), do: stock_last_price * total_shares

  defp to_integer(number) when is_float(number) do
    :erlang.float_to_binary(number, decimals: 2)
    |> String.replace(".", "")
    |> String.to_integer()
  end

  defp get_stock_last_price() do
    case Client.get_symbol_info() do
      {:ok, response} -> response["price"]
      {:error, _reason} -> []
    end
  end

  def create_order(user, attrs \\ %Order{}) do
    attrs = build_order_attrs(attrs, :buy)

    user
    |> Ecto.build_assoc(:orders)
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  defp build_order_attrs(attrs, :buy) do
    %{
      type: "buy",
      ticker_symbol: attrs["symbol"],
      unit_price: String.to_integer(attrs["price"]),
      shares_quantity: attrs["quantity"]
    }
  end
end
