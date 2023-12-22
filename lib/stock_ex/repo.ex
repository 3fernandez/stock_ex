defmodule StockEx.Repo do
  use Ecto.Repo,
    otp_app: :stock_ex,
    adapter: Ecto.Adapters.Postgres
end
