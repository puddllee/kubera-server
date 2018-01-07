defmodule Kubera.Repo.Migrations.CreateCoins do
  use Ecto.Migration

  def change do
    create table(:coins) do
      add :name, :string
      add :symbol, :string
      add :image, :string
      add :rank, :integer

      timestamps()
    end

    create unique_index(:coins, [:symbol])

  end
end
