defmodule Garden.Plans.Layout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "layouts" do
    field(:name, :string)

    has_many(:beds, Garden.Plans.Bed)
    has_many(:strategies, Garden.Plans.Strategy)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(layout, attrs) do
    layout
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
