defmodule Garden.Repo.Migrations.CreateStrategyAndPlans do
  use Ecto.Migration

  def change do
    create table(:strategies) do
      add(:name, :string)
      add(:description, :text)
      add(:score, :float)

      add(:layout_id, references(:layouts, on_delete: :nothing))

      timestamps(type: :utc_datetime)
    end

    create(index(:strategies, [:layout_id]))

    create table(:plans) do
      add(:area, :float)
      add(:strategy_id, references(:strategies, on_delete: :nothing))
      add(:bed_id, references(:beds, on_delete: :nothing))
      add(:plant_id, references(:plants, on_delete: :nothing))

      timestamps(type: :utc_datetime)
    end

    create(index(:plans, [:strategy_id]))
    create(index(:plans, [:bed_id]))
    create(index(:plans, [:plant_id]))
  end
end
