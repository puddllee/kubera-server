defmodule Kubera.Crypto do
  @moduledoc """
  The Crypto context.
  """

  import Ecto.Query, warn: false
  alias Kubera.Repo

  alias Kubera.Crypto.Coin
  alias Kubera.Crypto.Api

  def history_cache_ttl do
    %{
      "1day" => 5 * 60 * 1000, # 5 minutes
      "7day" => 60 * 60 * 1000, # 60 minutes
      "30day" => 6 * 60 * 60 * 1000, # 6 hours
      "90day" => 1 * 24 * 60 * 60 * 1000, # 1 day
      "180day" => 6 * 24 * 60 * 60 * 1000, # 6 days
      "365day" => 7 * 24 * 60 * 60 * 1000, # 7 days
    }
  end

  @doc """
  Returns the list of coins.

  ## Examples

      iex> list_coins()
      [%Coin{}, ...]

  """
  def list_coins do
    from(c in Coin,
      order_by: [asc: :rank])
    |> Repo.all()
  end

  @doc """
  Gets a single coin.

  Raises `Ecto.NoResultsError` if the Coin does not exist.

  ## Examples

      iex> get_coin!(123)
      %Coin{}

      iex> get_coin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coin!(id), do: Repo.get!(Coin, id)

  def get_coin_by_symbol(symbol) do
    case Repo.get_by(Coin, symbol: symbol) do
      %Coin{} = coin -> {:ok, coin}
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Creates a coin.

  ## Examples

      iex> create_coin(%{field: value})
      {:ok, %Coin{}}

      iex> create_coin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coin(attrs \\ %{}) do
    %Coin{}
    |> Coin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a coin.

  ## Examples

      iex> update_coin(coin, %{field: new_value})
      {:ok, %Coin{}}

      iex> update_coin(coin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_coin(%Coin{} = coin, attrs) do
    coin
    |> Coin.changeset(attrs)
    |> Repo.update()
  end

  def upsert_coin(attrs \\ %{}) do
    case Repo.get_by(Coin, symbol: Map.get(attrs, :symbol)) do
      %Coin{} = coin ->
        update_coin(coin, attrs)
      nil ->
        create_coin(attrs)
    end
  end

  @doc """
  Deletes a Coin.

  ## Examples

      iex> delete_coin(coin)
      {:ok, %Coin{}}

      iex> delete_coin(coin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coin(%Coin{} = coin) do
    Repo.delete(coin)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coin changes.

  ## Examples

      iex> change_coin(coin)
      %Ecto.Changeset{source: %Coin{}}

  """
  def change_coin(%Coin{} = coin) do
    Coin.changeset(coin, %{})
  end

  def save_coinlist do
    case Api.fetch_coins do
      {:ok, coins} -> Enum.map(coins, &upsert_coin/1)
      {:error, reason} -> IO.inspect reason
    end
  end

  def fetch_history(freq, symbol) do
    key = "HIST_#{symbol}_#{freq}"
    ttl = Map.get(history_cache_ttl(), freq, 5 * 60 * 1000)
    case Cachex.get(:coin_cache, key) do
      {:ok, history} ->
        {:ok, :hit, history}
      {:missing, _} ->
        case fetch_history_from_api(freq, symbol) do
          {:ok, history} ->
            Cachex.set(:coin_cache, key, history, ttl: ttl)
            {:ok, :miss, history}
          err ->
            err
        end
    end
  end

  def fetch_history_from_api(freq, symbol) do
    with {:ok, _} <- get_coin_by_symbol(symbol),
         {:ok, data} <- Api.fetch_history(freq, symbol)
      do
         {:ok, data}
      else
        err -> case err do
                 {:error, reason} -> {:error, reason}
                 _ -> {:error, :unknown_error}
               end
    end
  end

  def fetch_all_sparklines do
    list_coins
    |> Enum.map(fn c -> Map.get(c, :symbol) end)
    |> Enum.map(fn s -> fetch_coin_sparkline(s) end)
    |> Enum.filter(&ok?/1)
    |> Enum.reduce(%{}, fn({:ok, spark}, acc) ->
      Map.put(acc, Map.get(spark, :symbol), Map.get(spark, :prices))
    end)
  end

  def fetch_coin_sparkline(symbol) do
    case fetch_history("7day", symbol) do
      {:ok, history} ->
        history = history
        # |> filter_history_within_days(3)
        |> sparsify(25)
        {:ok, %{symbol: symbol, prices: history}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def filter_history_within_days(history, days) do
    days_ago = Timex.now
    |> Timex.shift(days: days * -1)
    |> DateTime.to_unix

    IO.inspect days_ago

    history
    |> Enum.filter(fn h ->
      Map.get(h, "ts") >= days_ago
    end)
  end

  def ok?({:ok, _}), do: true
  def ok?(_), do: false

  def sparsify(list, max_count) do
    cond do
      Enum.count(list) <= max_count -> list
      true ->
        step = Enum.count(list) / max_count
        sparsify_recur([], list, 1, step, step)
    end
  end

  defp sparsify_recur(l1, [], _, _, _), do: Enum.reverse(l1)
  defp sparsify_recur(l1, [x | xs], i, n, step) when i >= n do
    sparsify_recur([x | l1], xs, i + 1, n + step, step)
  end
  defp sparsify_recur(l1, [_ | xs], i, n, step) do
    sparsify_recur(l1, xs, i + 1, n, step)
  end
end
