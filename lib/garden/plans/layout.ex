defmodule Garden.Plans.Layout do
  alias Garden.Plans.Bed
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :beds, :strategies]}

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

  @doc false
  def changeset_with_beds(layout, attrs) do
    # note: there is no update layout functionality yet. If there was
    #       then you'd need to ensure another version of ensure_no_beds_overlap()
    #       was implemented that took into account existing beds. As we are creating
    #       beds then overlapping could only happen between the beds in the changeset
    layout
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_assoc(:beds, with: &Bed.changeset_for_layout/2)
    |> validate_no_beds_overlap()
  end

  def validate_no_beds_overlap(%Ecto.Changeset{changes: %{beds: bed_changesets}} = changeset) do
    put_change(changeset, :beds, overlaps?(bed_changesets))
  end

  def validate_no_beds_overlap(changeset), do: changeset

  def overlaps?(beds) do
    do_overlaps?(beds, [])
  end

  defp do_overlaps?([], changesets), do: changesets

  defp do_overlaps?([bed | beds], new_bed_changesets) do
    # map beds into [ %{x: x, y: y, l: l, w: w }, ...]
    geom = changeset_to_geom(bed)
    geoms = Enum.map(beds, &changeset_to_geom/1)

    # if this in those, update the changeset with an error
    bed =
      if overlaps_any?(geom, geoms) do
        add_error(
          bed,
          :base,
          "Bed at x: %{x}, y: %{y} with length: %{l} and width: %{w} overlaps another bed",
          [x: geom.x, y: geom.y, l: geom.l, w: geom.w]
        )
      else
        bed
      end

    do_overlaps?(beds, [bed | new_bed_changesets])
  end

  defp changeset_to_geom(cs) do
    %{
      x: get_field(cs, :x),
      y: get_field(cs, :y),
      l: get_field(cs, :l),
      w: get_field(cs, :w)
    }
  end

  @doc """
  Detects overlap on a new bed against existing beds.
  Currently uses primitive collision detection (AABB).

  Set up to allow touching.
  """
  def overlaps_any?(new_bed, existing_beds) do
    Enum.any?(existing_beds, fn bed ->
      not (new_bed.x + new_bed.w <= bed.x or
             new_bed.x >= bed.x + bed.w or
             new_bed.y + new_bed.l <= bed.y or
             new_bed.y >= bed.y + bed.l)
    end)
  end
end
