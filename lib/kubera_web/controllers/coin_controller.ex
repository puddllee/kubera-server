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

  def price(conn, %{"symbol" => symbol} = params) do
    freq = Map.get(params, "freq", "histominute")
    data = Crypto.fetch_coin(freq, symbol, [
          "toTs": Map.get(params, "from", DateTime.to_unix(Timex.now)),
          "aggregate": Map.get(params, "aggregate", "2"),
          "tsym": Map.get(params, "tsym", "USD")
        ])
    render(conn, "price.json", symbol: symbol, data: data)
  end
  def price(conn, _) do
   send_error(conn, 400)
  end

end
