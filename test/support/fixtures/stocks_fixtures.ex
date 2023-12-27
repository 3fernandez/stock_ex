defmodule StockEx.StocksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StockEx.Stocks` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, user} =
      StockEx.Accounts.register_user(%{email: "test@email.app", password: "strongest123"})

    order_attrs =
      Enum.into(attrs, %{"quantity" => 1, "symbol" => "VTI", "price" => "42"})

    {:ok, order} = StockEx.Stocks.create_order(user, order_attrs)

    order
  end
end
