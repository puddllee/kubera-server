defmodule Kubera.Crypto.Api do

  @cryptocompare_base "https://min-api.cryptocompare.com/data/"
  @coinlist "all/coinlist"
  @histominute "histominute"
  @histohour "histohour"
  @histoday "histoday"

  @coinmarketcap "https://api.coinmarketcap.com/v1/ticker/"

  @coincap "https://coincap.io/"

  def fetch_coins do
    case fetch_coinmarketcap do
      {:ok, coins} ->
        ccompare = fetch_cryptocompare()
        coins = coins
        |> Enum.map(fn c ->
          ccompare_coin = Map.get(ccompare, Map.get(c, :symbol), %{})
          image = Map.get(ccompare_coin, "ImageUrl", "")
          Map.put(c, :image, "https://www.cryptocompare.com#{image}")
        end)
        coins
      {:error, _} -> []
    end
  end

  def fetch_cryptocompare do
    case HTTPoison.get(@cryptocompare_base <> @coinlist) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Poison.decode!(body)
        Map.get(decoded, "Data")
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
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

  def fetch_history(freq, symbol, opts \\ []) do
    case HTTPoison.get(@coincap <> "history/" <> freq <> "/" <> symbol) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Poison.decode!(body)

        price = Map.get(decoded, "price")
        market_cap = Map.get(decoded, "market_cap")
        volume = Map.get(decoded, "volume")

        [price, market_cap, volume]
        |> Enum.zip
        |> Enum.map (fn d ->
          {[ts, price], [_, mc], [_, v]} = d
          %{"ts" => ts,
            "price" => price,
            "market_cap" => mc,
            "volume" => div(v, 1000)}
        end)
      {:error, %HTTPoison.Error{reason: reason}} ->
        reason
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
