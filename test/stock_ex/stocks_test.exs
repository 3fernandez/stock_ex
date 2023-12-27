defmodule StockEx.StocksTest do
  use StockEx.DataCase

  import StockEx.AccountsFixtures
  import StockEx.StocksFixtures

  alias StockEx.Stocks
  alias StockEx.Stocks.Order

  describe "orders" do
    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Stocks.list_orders() == [order]
    end

    test "create_order/1 with valid data creates a order" do
      user = user_fixture()

      valid_attrs = %{
        "name" => "Vanguard Group, Inc. - Vanguard Total Stock Market ETF",
        "price" => "42",
        "quantity" => 1,
        "symbol" => "VTI"
      }

      assert {:ok, %Order{} = order} = Stocks.create_order(user, valid_attrs)
      assert order.type == "buy"
      assert order.ticker_symbol == "VTI"
      assert order.unit_price == 42
      assert order.shares_quantity == 1
    end

    test "create_order/1 with invalid data returns error changeset" do
      user = user_fixture()

      invalid_attrs =
        %{
          "name" => "Vanguard Group, Inc. - Vanguard Total Stock Market ETF",
          "price" => "42",
          "quantity" => nil,
          "symbol" => nil
        }

      assert {:error, %Ecto.Changeset{}} = Stocks.create_order(user, invalid_attrs)
    end
  end
end
