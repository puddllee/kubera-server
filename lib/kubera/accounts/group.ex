defmodule Kubera.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kubera.Accounts.Group


  schema "groups" do
    field :buyin, :integer
    field :joinable, :boolean, default: true
    field :name, :string

    many_to_many :users, Kubera.Accounts.User, join_through: "users_groups"
    timestamps()
  end

  @doc false
  def changeset(%Group{} = group, attrs) do
    group
    |> cast(attrs, [:name, :buyin])
    |> validate_required([:name, :buyin])
  end
end
