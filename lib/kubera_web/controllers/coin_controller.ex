defmodule KuberaWeb.CoinController do
  use KuberaWeb, :controller

  alias Kubera.Crypto
  alias Kubera.Crypto.Coin

  action_fallback KuberaWeb.FallbackController

  def index(conn, _params) do
    coins = Crypto.list_coins()
    render(conn, "index.json", coins: coins)
  end

  def show(conn, %{"id" => id}) do
    coin = Crypto.get_coin!(id)
    render(conn, "show.json", coin: coin)
  end

end
