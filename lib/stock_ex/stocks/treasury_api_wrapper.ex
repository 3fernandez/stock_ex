defmodule StockEx.Stocks.TreasuryApiWrapper do
  @moduledoc """
  Treasury API wrapper
  """

  use Tesla

  alias Tesla.Env

  plug Tesla.Middleware.Headers, [{"Authorization", "Bearer #{api_key()}"}]
  plug Tesla.Middleware.JSON

  @base_url "https://treasury.app/api/v1/hiring"

  @spec get_symbol_info(base_url :: String.t(), symbol :: String.t()) ::
          {:ok, map()} | {:error, map()}
  def get_symbol_info(base_url \\ @base_url, symbol \\ "VTI") when is_binary(symbol) do
    "#{base_url}/symbols/#{symbol}"
    |> get()
    |> handle_get()
  end

  defp handle_get({:ok, %Env{status: 200, body: body}}), do: {:ok, body}

  defp handle_get({:error, _reason}) do
    {:error, %{status: :bad_request, result: "Symbol not found"}}
  end

  defp api_key(), do: Application.get_env(:stock_ex, :treasury_api_key)
end
