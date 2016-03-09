defmodule Backend.Repo.Migrations.CreateGeo do
  use Ecto.Migration

  def change do
    create table(:geos) do
      add :tag, :string
      add :coords, :string
      add :lat, :float
      add :long, :float

      timestamps
    end

  end
end
