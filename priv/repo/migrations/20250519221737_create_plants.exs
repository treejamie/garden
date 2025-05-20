defmodule Garden.Repo.Migrations.CreatePlants do
  use Ecto.Migration

  def change do

    create table(:plants) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    # This is the join table for benefits_to and benefits_from
    create table(:plant_benefits, primary_key: :false) do
      add :benefits_from_id, references(:plants, on_delete: :nothing)
      add :benefits_to_id, references(:plants, on_delete: :nothing)
    end

    create index(:plant_benefits, [:benefits_from_id])
    create index(:plant_benefits, [:benefits_to_id])
    create unique_index(:plant_benefits, [:benefits_from_id, :benefits_to_id])

    # this is the join table for plants and soils
    create table(:plant_soils, primary_key: false) do
      add :plant_id, references(:plants, on_delete: :delete_all), null: false
      add :soil_id, references(:soils, on_delete: :delete_all), null: false
    end

    create unique_index(:plant_soils, [:plant_id, :soil_id])
  end
end
