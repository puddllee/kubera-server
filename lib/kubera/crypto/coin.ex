defmodule Kubera.Crypto.Coin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kubera.Crypto.Coin


  schema "coins" do
    field :image, :string
    field :name, :string
    field :symbol, :string
    field :rank, :integer
    field :price_btc, :float
    field :price_usd, :float
    field :marketcap, :float
    field :percent_change_1h, :float
    field :percent_change_24h, :float
    field :percent_change_7d, :float
    field :available_supply, :float
    field :max_supply, :float
    field :last_updated, :integer

    timestamps()
  end

  @doc false
  def changeset(%Coin{} = coin, attrs) do
    coin
    |> cast(attrs, [:name, :symbol, :rank, :image, :price_btc, :price_usd, :marketcap, :percent_change_1h, :percent_change_24h, :percent_change_7d, :available_supply, :max_supply, :last_updated])
    |> validate_required([:name, :symbol, :rank, :price_usd, :marketcap])
    |> unique_constraint(:symbol)
  end
end
