defmodule KuberaWeb.CoinView do
  use KuberaWeb, :view
  alias KuberaWeb.CoinView

  def render("index.json", %{coins: coins}) do
    %{data: render_many(coins, CoinView, "coin.json")}
  end

  def render("show.json", %{coin: coin}) do
    %{data: render_one(coin, CoinView, "coin.json")}
  end

  def render("coin.json", %{coin: coin}) do
    %{id: coin.id,
      name: coin.name,
      symbol: coin.symbol,
      image: coin.image}
  end
end
