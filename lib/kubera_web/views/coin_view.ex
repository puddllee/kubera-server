defmodule KuberaWeb.CoinView do
  use KuberaWeb, :view
  alias KuberaWeb.CoinView

  def render("index.json", %{coins: coins}) do
    render_many(coins, CoinView, "coin.json")
  end

  def render("show.json", %{coin: coin}) do
    render_one(coin, CoinView, "coin.json")
  end

  def render("price.json", %{symbol: symbol, data: data}) do
    %{symbol: symbol, data: data}
  end

  def render("coin.json", %{coin: coin}) do
    # Map.from_struct coin
    coin
    |> Map.from_struct
    |> Map.drop([:__meta__, :updated_at, :inserted_at])
  end

end
