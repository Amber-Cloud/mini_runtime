defmodule DataApi.Repo.Migrations.UpdateCatsTablePhotosAndGender do
  use Ecto.Migration

  def change do
    alter table(:cats) do
      remove :image_url
      add :gender, :string
      add :photos, :text
    end
  end
end
