defmodule StockEx.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :type, :string
      add :ticker_symbol, :string
      add :unit_price, :integer
      add :shares_quantity, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:user_id])
    create index(:orders, [:user_id, :type, :ticker_symbol], name: "users_orders")
  end
end
