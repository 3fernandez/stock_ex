defmodule StockEx.Stocks.StockStruct do
  use ExConstructor

  defstruct [:name, :symbol, :price, :expense_ratio_basis_points, quantity: 1]
end
