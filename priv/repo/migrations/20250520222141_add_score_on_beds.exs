defmodule Garden.Repo.Migrations.AddScoreOnBeds do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      add(:scores, :float)
    end
  end
end
