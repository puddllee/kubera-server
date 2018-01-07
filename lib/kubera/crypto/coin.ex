defmodule Kubera.Crypto.Coin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kubera.Crypto.Coin


  schema "coins" do
    field :image, :string
    field :name, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(%Coin{} = coin, attrs) do
    coin
    |> cast(attrs, [:name, :symbol, :image])
    |> validate_required([:name, :symbol, :image])
  end
end
