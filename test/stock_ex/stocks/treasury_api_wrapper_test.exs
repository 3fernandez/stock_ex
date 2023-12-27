defmodule StockEx.Stocks.TreasuryApiWrapperTest do
  use ExUnit.Case, async: true

  alias Plug.Conn
  alias StockEx.Stocks.TreasuryApiWrapper, as: Client

  describe "get_symbol_info/1" do
    setup do
      bypass = Bypass.open()

      {:ok, bypass: bypass}
    end

    test "when the symbol is valid", %{bypass: bypass} do
      symbol = "VTI"
      url = endpoint_url(bypass.port)

      body = ~s({
       	"expense_ratio_basis_points": 3,
       	"name": "Vanguard Group, Inc. - Vanguard Total Stock Market ETF",
       	"price": 238.195,
       	"symbol": "VTI"
      })

      Bypass.expect(bypass, "GET", "/symbols/#{symbol}", fn conn ->
        conn
        |> Conn.put_resp_header("content-type", "application/json")
        |> Conn.resp(200, body)
      end)

      response = Client.get_symbol_info(url, symbol)

      expected_response =
        {:ok,
         %{
           "expense_ratio_basis_points" => 3,
           "name" => "Vanguard Group, Inc. - Vanguard Total Stock Market ETF",
           "price" => 238.195,
           "symbol" => "VTI"
         }}

      assert response == expected_response
    end

    test "when the symbol is valid or not found", %{bypass: bypass} do
      symbol = "VTIPIX"
      url = endpoint_url(bypass.port)

      Bypass.expect(bypass, "GET", "/symbols/#{symbol}", fn conn ->
        conn
        |> Conn.put_resp_header("content-type", "application/json")
        |> Conn.resp(404, "Not Found")
      end)

      response = Client.get_symbol_info(url, symbol)

      expected_response = {:error, %{status: :bad_request, result: "Symbol not found"}}

      assert response == expected_response
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
