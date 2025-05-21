defmodule Garden.Repo.Migrations.AddScoreOnBeds do
  use Ecto.Migration

  def change do
    alter table(:plans) do
      add(:score, :integer, default: 10)
    end

  end
end
