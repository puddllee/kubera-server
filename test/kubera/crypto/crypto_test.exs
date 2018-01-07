defmodule Kubera.CryptoTest do
  use Kubera.DataCase

  alias Kubera.Crypto

  describe "coins" do
    alias Kubera.Crypto.Coin

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

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
      assert coin.name == "some name"
    end

    test "create_coin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Crypto.create_coin(@invalid_attrs)
    end

    test "update_coin/2 with valid data updates the coin" do
      coin = coin_fixture()
      assert {:ok, coin} = Crypto.update_coin(coin, @update_attrs)
      assert %Coin{} = coin
      assert coin.name == "some updated name"
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
  end
end
