defmodule Kubera.Crypto.Api do

  alias Kubera.Crypto

  @base "https://min-api.cryptocompare.com/data/"
  @coinlist "all/coinlist"
  @histominute "histominute"

  def fetch_coinlist do
    case HTTPoison.get(@base <> @coinlist) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Poison.decode!(body)
        data = Map.get(decoded, "Data")
        data
        |> Map.values
        |> Enum.map(fn c ->
          %{ image: "#{"https://www.cryptocompare.com"}#{Map.get(c, "ImageUrl")}",
             name: Map.get(c, "CoinName"),
             symbol: Map.get(c, "Symbol"),
             rank: Map.get(c, "SortOrder")}
        end)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        []
    end
  end

  def fetch_coin(symbol, from_date), do: fetch_coin(symbol, "USD", from_date)
  def fetch_coin(symbol, to_symbol, from_date) do
    params = [
      {"fsym", symbol}, # from symbol
      {"tsym", to_symbol}, # to symbol
      {"limit", 2000},
      {"e", "CCCAGG"}, # exchange
      {"allData", "true"},
      {"toTs", to_string(from_date)}
    ]
    IO.inspect params
    case HTTPoison.get(@base <> @histominute, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Poison.decode!(body)
        Map.get(decoded, "Data")
      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
    end
  end
end
