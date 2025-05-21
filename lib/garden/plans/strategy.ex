defmodule Garden.Plans.Strategy do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name]}

  schema "strategies" do
    field(:name, :string)
    field(:description, :string)
    field(:score, :float)

    belongs_to(:layout, Garden.Plans.Layout)
    has_many(:plans, Garden.Plans.Plan)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(strategy, attrs) do
    strategy
    |> cast(attrs, [:name, :description, :score, :layout_id])
    |> validate_required([:name, :layout_id])
  end

  def score_changeset(strategy, attrs) do
    strategy
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end
end
