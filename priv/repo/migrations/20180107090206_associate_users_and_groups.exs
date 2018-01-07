defmodule Kubera.Repo.Migrations.AssociateUsersAndGroups do
  use Ecto.Migration

  def change do
    create table(:users_groups, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :group_id, references(:groups, on_delete: :delete_aler)
    end
  end
end
