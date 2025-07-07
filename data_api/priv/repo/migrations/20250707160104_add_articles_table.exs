defmodule DataApi.Repo.Migrations.AddArticlesTable do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string, null: false
      add :content, :text, null: false
      add :app_id, :string, null: false

      timestamps()
    end

    create index(:articles, [:app_id])
    create index(:articles, [:app_id, :id])
  end
end
