defmodule Kubera.Crypto.Apitest do
  use Kubera.DataCase

  alias Kubera.Crypto.Api

  describe "api" do
    test "fetch_coins/0 gets a list of coin data" do
      coins = Api.fetch_coins()
      assert (Enum.count coins) > 0
    end

    test "fetch_history/3 gets history data for a coin" do
      ["1day", "7day", "30day", "90day", "180day", "365day"]
      |> Enum.map(fn freq ->
        {:ok, history} = Api.fetch_history(freq, "ETH")
        assert (Enum.count history) > 1
      end)
    end
  end
end
