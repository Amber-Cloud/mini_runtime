defmodule DataApi.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :app_id, :string, null: false

      timestamps()
    end

    create index(:users, [:app_id])
    create index(:users, [:app_id, :id])
    create unique_index(:users, [:app_id, :email])
  end
end
