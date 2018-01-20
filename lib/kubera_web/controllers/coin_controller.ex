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

  def show(conn, %{"symbol" => symbol}) do
    case Crypto.get_coin_by_symbol(symbol) do
      {:ok, %Coin{} = coin} ->
        render(conn, "show.json", coin: coin)
      {:error, _} ->
        send_error(conn, 404)
    end
  end

  def price(conn, %{"freq" => freq, "symbol" => symbol}) do
    case Crypto.fetch_history(freq, symbol) do
      {:ok, _, data} ->
        render(conn, "price.json", symbol: symbol, data: data)
      {:error, :not_found} ->
        send_error(conn, 404)
      {:error, reason} ->
        send_error(conn, 400, reason)
    end
  end
  def price(conn, _) do
   send_error(conn, 400)
  end

  def sparklines(conn, _params) do
    case Crypto.fetch_all_sparklines do
      {:ok, lines} ->
        render(conn, "sparklines.json", sparklines: lines)
      {:error, _} ->
        send_error(conn, 404)
    end
  end

end
