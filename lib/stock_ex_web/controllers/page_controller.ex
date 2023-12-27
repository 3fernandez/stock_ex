defmodule StockExWeb.PageController do
  use StockExWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/")
  end
end
