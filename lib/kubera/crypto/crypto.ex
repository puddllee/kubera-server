defmodule Kubera.Crypto do
  @moduledoc """
  The Crypto context.
  """

  import Ecto.Query, warn: false
  alias Kubera.Repo

  alias Kubera.Crypto.Coin

  @doc """
  Returns the list of coins.

  ## Examples

      iex> list_coins()
      [%Coin{}, ...]

  """
  def list_coins do
    []
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

end
