defmodule Kubera.Crypto do
  @moduledoc """
  The Crypto context.
  """

  import Ecto.Query, warn: false
  alias Kubera.Repo

  alias Kubera.Crypto.Coin
  alias Kubera.Crypto.Api

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
    # IO.puts "Upserting with symbol #{attrs.symbol}"
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
    Api.fetch_coins
    |> Enum.map(&upsert_coin/1)
  end

  def fetch_history(freq, symbol, opts \\ []) do
    case Api.fetch_history(freq, symbol) do
      {:ok, data} -> {:ok, data}
      {:error, :timeout} -> {:error, "timeout"}
      _ ->
        {:error, "unknown_error"}
    end
  end
end
