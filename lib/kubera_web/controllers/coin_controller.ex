defmodule KuberaWeb.CoinController do
  use KuberaWeb, :controller

  alias Kubera.Crypto
  alias Kubera.Crypto.Coin
  import KuberaWeb.ErrorView

  action_fallback KuberaWeb.FallbackController

  def index(conn, _params) do
    coins = Crypto.list_coins()
    render(conn, "index.json", coins: coins)
  end

  def show(conn, %{"id" => id}) do
    coin = Crypto.get_coin!(id)
    render(conn, "show.json", coin: coin)
  end

  def price(conn, %{"symbol" => symbol, "from" => from, "freq" => freq}) do
    data = Crypto.fetch_coin(freq, symbol, [
          "toTs": from
        ])
    render(conn, "price.json", symbol: symbol, data: data)
  end
  def price(conn, _) do
   send_error(conn, 400)
  end

end
