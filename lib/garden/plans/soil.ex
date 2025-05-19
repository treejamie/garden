defmodule Garden.Plans.Soil do
  use Ecto.Schema
  import Ecto.Changeset

  schema "soils" do
    field :name, :string

    has_many(:beds, Garden.Plans.Bed)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(soil, attrs) do
    soil
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
