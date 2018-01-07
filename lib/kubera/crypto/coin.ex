defmodule Kubera.Crypto.Coin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kubera.Crypto.Coin


  schema "coins" do
    field :name, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(%Coin{} = coin, attrs) do
    coin
    |> cast(attrs, [:name, :symbol])
    |> validate_required([:name, :symbol])
  end
end
