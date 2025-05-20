defmodule Garden.Repo.Migrations.CreateSoils do
  use Ecto.Migration

  def change do
    create table(:soils) do
      add :name, :string
      timestamps(type: :utc_datetime)
    end

    alter table(:beds) do
      add(:soil_id, references(:soils, on_delete: :nothing))
    end

  end
end
