defmodule Kubera.Crypto.Api do

  alias Kubera.Crypto

  @cryptocompare_base "https://min-api.cryptocompare.com/data/"
  @coinlist "all/coinlist"
  @histominute "histominute"
  @histohour "histohour"
  @histoday "histoday"

  @coinmarketcap "https://api.coinmarketcap.com/v1/ticker/"

  def fetch_coins do
    IO.puts "write me!"
  end
  def fetch_coinlist do
    case HTTPoison.get(@cryptocompare_base <> @coinlist) do
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

  def fetch_coinmarketcap do
    case HTTPoison.get(@coinmarketcap) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        coins = Poison.decode!(body)
        |> Enum.map(fn c ->
          %{name: Map.get(c, "name"),
            symbol: Map.get(c, "symbol"),
            rank: Map.get(c, "rank"),
            price_btc: Map.get(c, "price_btc"),
            price_usd: Map.get(c, "price_usd"),
            marketcap: Map.get(c, "market_cap_usd"),
            percent_change_1h: Map.get(c, "percent_change_1h"),
            percent_change_24h: Map.get(c, "percent_change_24h"),
            percent_change_7d: Map.get(c, "percent_change_7d"),
            available_supply: Map.get(c, "available_supply"),
            max_supply: Map.get(c, "total_supply"),
            last_updated: Map.get(c, "last_updated")}
        end)
        {:ok, coins}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        {:error, reason}
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

    case HTTPoison.get(@cryptocompare_base <> freq, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Poison.decode!(body)
        Map.get(decoded, "Data")
      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
    end
  end
  
end
