defmodule DataApi.Repo.Migrations.AddCommentsTable do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text, null: false
      add :article_id, :integer, null: false
      add :app_id, :string, null: false

      timestamps()
    end

    create index(:comments, [:app_id])
    create index(:comments, [:app_id, :id])
    create index(:comments, [:app_id, :article_id])
  end
end
