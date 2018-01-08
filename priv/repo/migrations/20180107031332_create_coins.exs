defmodule Kubera.Repo.Migrations.CreateCoins do
  use Ecto.Migration

  def change do
    create table(:coins) do
      add :name, :string
      add :symbol, :string
      add :image, :string
      add :rank, :integer
      add :price_btc, :float
      add :price_usd, :float
      add :marketcap, :float
      add :percent_change_1h, :float
      add :percent_change_24h, :float
      add :percent_change_7d, :float
      add :available_supply, :float
      add :max_supply, :float
      add :last_updated, :integer

      timestamps()
    end

    create unique_index(:coins, [:symbol])

  end
end
