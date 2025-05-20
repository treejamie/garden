defmodule Garden.Repo.Migrations.CreateBeds do
  use Ecto.Migration

  def change do
    create table(:beds) do
      add :x, :float
      add :y, :float
      add :l, :float
      add :w, :float
      add :area, :float
      add :layout_id, references(:layouts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:beds, [:layout_id])
  end
end
