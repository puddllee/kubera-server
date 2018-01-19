defmodule Kubera.Crypto.Api do

  @cryptocompare_base "https://min-api.cryptocompare.com/data/"
  @coinlist "all/coinlist"
  @histominute "histominute"
  @histohour "histohour"
  @histoday "histoday"

  @coinmarketcap "https://api.coinmarketcap.com/v1/ticker/"

  @coincap "https://coincap.io/"

  def fetch_coins do
    with   {:ok, coins} <- fetch_coinmarketcap(),
           {:ok, ccompare_coins} <- fetch_cryptocompare(),
           coins <- add_images_to_coins(coins, ccompare_coins),
           {:ok, symbollist} <- fetch_coincaplist()
      do
        {:ok, filter_coins_by_symbollist(coins, symbollist)}
      else
        err -> {:error, err}
      end
  end

  def filter_coins_by_symbollist(coins, symbollist) do
    Enum.filter(coins, fn c -> Map.get(c, :symbol) in symbollist end)
  end

  def add_images_to_coins(coins, ccompare_coins) do
    Enum.map(coins, fn c ->
      ccoin = Map.get(ccompare_coins, Map.get(c, :symbol), %{})
      image = Map.get(ccoin, "ImageUrl", "")
      Map.put(c, :image, "https://www.cryptocompare.com#{image}")
    end)
  end

  def fetch_cryptocompare do
    case HTTPoison.get(@cryptocompare_base <> @coinlist) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded = Poison.decode!(body)
        {:ok, Map.get(decoded, "Data")}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
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
        {:error, reason}
    end
  end

  def fetch_coincaplist do
    case HTTPoison.get(@coincap <> "coins/") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode(body)
      {:error, %HTTPoison.Error{reason: reason}} ->
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

        history = [price, market_cap, volume]
        |> Enum.zip
        |> Enum.map(fn d ->
          {[ts, price], [_, mc], [_, v]} = d
          %{"ts" => ts,
            "price" => price,
            "market_cap" => mc,
            "volume" => div(v, 1000)}
        end)

        {:ok, history}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
