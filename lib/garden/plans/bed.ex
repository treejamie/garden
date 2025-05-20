defmodule Garden.Plans.Bed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "beds" do
    field(:w, :float)
    field(:l, :float)
    field(:y, :float)
    field(:x, :float)
    field(:area, :float)

    belongs_to(:soil, Garden.Plans.Soil)
    belongs_to(:layout, Garden.Plans.Layout)

    has_many(:plans, Garden.Plans.Plan)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bed, attrs) do
    bed
    |> cast(attrs, [:x, :y, :l, :w, :area, :layout_id, :soil_id])
    |> validate_required([:x, :y, :l, :w, :layout_id, :soil_id])
    |> validate_number(:l, greater_than_or_equal_to: 1)
    |> validate_number(:w, greater_than_or_equal_to: 1)
    |> calculate_area()
  end

  defp calculate_area(changeset) do
    with {:ok, l} <- fetch_change(changeset, :l),
         {:ok, w} <- fetch_change(changeset, :w) do
      put_change(changeset, :area, l * w)
    else
      _ -> changeset
    end
  end
end
