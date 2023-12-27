defmodule StockEx.Stocks.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :type, :string
    field :ticker_symbol, :string
    field :unit_price, :integer
    field :shares_quantity, :integer
    belongs_to :user, StockEx.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:type, :ticker_symbol, :unit_price, :shares_quantity, :user_id])
    |> validate_required([:type, :ticker_symbol, :unit_price, :shares_quantity, :user_id])
  end
end
