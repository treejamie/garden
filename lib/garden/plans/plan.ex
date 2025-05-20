defmodule Garden.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plans" do
    field(:area, :float)

    belongs_to(:bed, Garden.Plans.Bed)
    belongs_to(:plant, Garden.Plans.Plant)
    belongs_to(:layout, Garden.Plans.Layout)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:area, :bed_id, :plant_id, :layout_id])
    |> validate_required([:area])
  end
end
