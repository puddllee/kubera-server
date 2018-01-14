defmodule KuberaWeb.CoinControllerTest do
  use KuberaWeb.ConnCase

  alias Kubera.Crypto

  @valid_attrs %{
    image: "some image",
    name: "Etherum",
    symbol: "ETH",
    rank: 1,
    price_btc: 0.5,
    price_usd: 1000,
    marketcap: 1000000,
    percent_change_1h: 1.2,
    percent_change_24h: -23.4,
    percent_change_7d: 100.001,
    available_supply: 1000,
    max_supply: 100,
    last_updated: 1000000}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all coins", %{conn: conn} do
      conn = get conn, coin_path(conn, :index)
      assert json_response(conn, 200) == []
    end
  end

  describe "show" do
    setup [:create_coin]

    test "get a specific coin", %{conn: conn} do
      conn = get conn, coin_path(conn, :show, "ETH")
      res = json_response(conn, 200)
      assert Map.get(res, "symbol") == "ETH"
    end
  end

  describe "history" do
    setup [:create_coin]

    test "get a coins history", %{conn: conn} do
      conn = get conn, coin_path(conn, :price, "1day", "ETH")
      res = json_response(conn, 200)
      assert Map.get(res, "symbol") == "ETH"
    end
  end

  defp create_coin(_) do
    {:ok, coin: Crypto.create_coin(@valid_attrs)}
  end
end
