defmodule Kubera.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kubera.Accounts.Group


  schema "groups" do
    field :buyin, :integer
    field :joinable, :boolean, default: true
    field :name, :string
    field :uid, :string

    many_to_many :users, Kubera.Accounts.User, join_through: "users_groups"
    timestamps()
  end

  @doc false
  def changeset(%Group{} = group, attrs) do
    IO.puts "\n---"
    IO.inspect group
    group
    |> cast(attrs, [:name, :buyin, :joinable, :uid])
    |> IO.inspect
    |> validate_required([:name, :buyin, :joinable, :uid])
  end
end
