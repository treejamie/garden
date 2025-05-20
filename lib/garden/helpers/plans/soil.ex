defmodule Garden.Plans.Soil do
  use Ecto.Schema
  import Ecto.Changeset


  @derive {Jason.Encoder, only: [:name, :plants]}
  schema "soils" do
    field :name, :string

    has_many(:beds, Garden.Plans.Bed)

    many_to_many(:plants, Garden.Plans.Plant,
      join_through: "plant_soils",
      on_replace: :delete,
      join_keys: [soil_id: :id, plant_id: :id]
    )

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(soil, attrs) do
    soil
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
