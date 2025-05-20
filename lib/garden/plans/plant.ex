defmodule Garden.Plans.Plant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plants" do
    field :name, :string

    many_to_many(:soils, Garden.Plans.Soil,
      join_through: "plant_soils",
      # I was not sure about :delete vs :delete_if_exists
      # https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3-on_replace
      on_replace: :delete,
      join_keys: [plant_id: :id, soil_id: :id]
    )

    many_to_many(:benefits_from, __MODULE__,
      join_through: "plant_benefits",
      join_keys: [benefits_to_id: :id, benefits_from_id: :id]
    )

    many_to_many(:benefits_to, __MODULE__,
      join_through: "plant_benefits",
      join_keys: [benefits_from_id: :id, benefits_to_id: :id]
    )



    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plant, attrs) do
    plant
    |> cast(attrs, [:name])
    |> validate_required([:name])

  end
end
