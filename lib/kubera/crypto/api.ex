defmodule Kubera.Crypto.Api do

  alias Kubera.Crypto

  @base "https://www.cryptocompare.com/api/data/"
  @coinlist "coinlist"

  def save_coinlist do
    coins = fetch_coinlist()
    coins |> Enum.map(&Crypto.upsert_coin/1)
  end

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
             symbol: Map.get(c, "Symbol")}
        end)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        []
    end
  end
end
