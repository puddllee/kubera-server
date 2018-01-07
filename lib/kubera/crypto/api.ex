defmodule Kubera.Crypto.Api do

  alias Kubera.Crypto

  @base "https://min-api.cryptocompare.com/data/"
  @coinlist "all/coinlist"
  @histominute "histominute"
  @histohour "histohour"
  @histoday "histoday"

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

  def fetch_coin(freq, symbol, opts \\ []) do
    opts = Keyword.merge([
      "tsym": "USD",
      "limit": 2000,
      "e": "CCCAGG",
      "aggregate": "2",
      "fsym": symbol
    ], opts)
    params = Keyword.keys(opts)
    |> Enum.map(fn k -> {k, Keyword.get(opts, k)} end)

    case HTTPoison.get(@base <> freq, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Poison.decode!(body)
        Map.get(decoded, "Data")
      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
    end
  end
end
