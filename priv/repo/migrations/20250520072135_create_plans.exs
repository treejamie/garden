defmodule Garden.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :area, :float
      add :bed_id, references(:beds, on_delete: :nothing)
      add :plant_id, references(:plants, on_delete: :nothing)
      add :layout_id, references(:layouts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:plans, [:bed_id])
    create index(:plans, [:plant_id])
    create index(:plans, [:layout_id])
  end
end
