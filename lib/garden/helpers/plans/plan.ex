defmodule Garden.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset


  @derive {Jason.Encoder, only: [:id, :area, :bed, :plant]}
  schema "plans" do
    field(:area, :float)

    belongs_to(:bed, Garden.Plans.Bed)
    belongs_to(:plant, Garden.Plans.Plant)
    belongs_to(:strategy, Garden.Plans.Strategy)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:area, :bed_id, :plant_id, :strategy_id])
    |> validate_required([:area])
  end
end
