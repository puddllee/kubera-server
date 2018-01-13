defmodule Kubera.CryptoTest do
  use Kubera.DataCase

  alias Kubera.Crypto

  describe "coins" do
    alias Kubera.Crypto.Coin

    @valid_attrs %{
      image: "some image",
      name: "some name",
      symbol: "some symbol",
      rank: 1,
      price_btc: 0.5,
      price_usd: 1000,
      marketcap: 1000000,
      percent_change_1h: 1.2,
      percent_change_24h: -23.4,
      percent_change_7d: 100.001,
      available_supply: 1000,
      max_supply: 100,
      last_update: 1000000}
    @update_attrs %{image: "some updated image", name: "some updated name", symbol: "some updated symbol"}
    @invalid_attrs %{image: nil, name: nil, symbol: nil}

    def coin_fixture(attrs \\ %{}) do
      {:ok, coin} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Crypto.create_coin()

      coin
    end

    test "list_coins/0 returns all coins" do
      coin = coin_fixture()
      assert Crypto.list_coins() == [coin]
    end

    test "get_coin!/1 returns the coin with given id" do
      coin = coin_fixture()
      assert Crypto.get_coin!(coin.id) == coin
    end

    test "create_coin/1 with valid data creates a coin" do
      assert {:ok, %Coin{} = coin} = Crypto.create_coin(@valid_attrs)
      assert coin.image == "some image"
      assert coin.name == "some name"
      assert coin.symbol == "some symbol"
    end

    test "create_coin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Crypto.create_coin(@invalid_attrs)
    end

    test "update_coin/2 with valid data updates the coin" do
      coin = coin_fixture()
      assert {:ok, coin} = Crypto.update_coin(coin, @update_attrs)
      assert %Coin{} = coin
      assert coin.image == "some updated image"
      assert coin.name == "some updated name"
      assert coin.symbol == "some updated symbol"
    end

    test "update_coin/2 with invalid data returns error changeset" do
      coin = coin_fixture()
      assert {:error, %Ecto.Changeset{}} = Crypto.update_coin(coin, @invalid_attrs)
      assert coin == Crypto.get_coin!(coin.id)
    end

    test "delete_coin/1 deletes the coin" do
      coin = coin_fixture()
      assert {:ok, %Coin{}} = Crypto.delete_coin(coin)
      assert_raise Ecto.NoResultsError, fn -> Crypto.get_coin!(coin.id) end
    end

    test "change_coin/1 returns a coin changeset" do
      coin = coin_fixture()
      assert %Ecto.Changeset{} = Crypto.change_coin(coin)
    end

    test "save_coinlist/0 saves coins into the db" do
      Crypto.save_coinlist()
      coins = Crypto.list_coins()

      assert (Enum.count coins) > 0
    end

    test "fetch_history/3 gets coin history data" do
      ["1day", "7day", "30day", "90day", "180day", "365day"]
      |> Enum.map(fn freq ->
        {:ok, history} = Crypto.fetch_history(freq, "ETH")
        assert (Enum.count history) > 1
      end)
    end
  end
end
