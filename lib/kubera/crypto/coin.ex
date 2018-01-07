defmodule Kubera.Crypto.Coin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kubera.Crypto.Coin


  schema "coins" do
    field :image, :string
    field :name, :string
    field :symbol, :string
    field :rank, :integer

    timestamps()
  end

  @doc false
  def changeset(%Coin{} = coin, attrs) do
    coin
    |> cast(attrs, [:name, :symbol, :image, :rank])
    |> validate_required([:name, :symbol, :image, :rank])
    |> unique_constraint(:symbol)
  end
end
