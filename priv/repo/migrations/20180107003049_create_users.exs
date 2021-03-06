defmodule Kubera.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :auth_provider, :string
      add :first_name, :string
      add :last_name, :string
      add :avatar, :string

      timestamps()
    end

  end
end
