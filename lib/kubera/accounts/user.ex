defmodule Kubera.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kubera.Accounts.User


  schema "users" do
    field :auth_provider, :string
    field :avatar, :string
    field :first_name, :string
    field :last_name, :string
    field :name, :string
    field :email, :string

    many_to_many :groups, Kubera.Accounts.Group, join_through: "users_groups"
    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :auth_provider, :first_name, :last_name, :avatar, :email])
    |> validate_required([:name, :auth_provider, :first_name, :last_name, :avatar, :email])
  end
end
