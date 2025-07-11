defmodule DataApi.Repo.Migrations.CreateCatsTable do
  use Ecto.Migration

  def change do
    create table(:cats) do
      add :name, :string, null: false
      add :age, :integer, null: false
      add :breed, :string
      add :description, :text
      add :image_url, :string
      add :adoption_status, :string, default: "available"
      add :color, :string
      add :app_id, :string, null: false
      add :inserted_at, :string
      add :updated_at, :string
    end

    create index(:cats, [:app_id])
    create index(:cats, [:app_id, :adoption_status])
  end
end
