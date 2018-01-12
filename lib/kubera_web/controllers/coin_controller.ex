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

  def price(conn, %{"freq" => freq, "symbol" => symbol} = params) do
    case Crypto.fetch_history(freq, symbol) do
      {:ok, data} ->
        render(conn, "price.json", symbol: symbol, data: data)
      {:error, reason} ->
        send_error(conn, 503, reason)
    end
  end
  def price(conn, _) do
   send_error(conn, 400)
  end

end
