defmodule Garden.Plans.Layout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "layouts" do
    field(:name, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(layout, attrs) do
    layout
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
