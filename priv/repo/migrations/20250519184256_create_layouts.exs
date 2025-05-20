defmodule Garden.Repo.Migrations.CreateLayouts do
  use Ecto.Migration

  def change do
    create table(:layouts) do
      add(:name, :string)
      timestamps(type: :utc_datetime)
    end
  end
end
