defmodule Garden.Plans do
  @moduledoc """
  The Plan context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Garden.Repo

  alias Garden.Plans.{Layout, Soil, Plant}

  @doc """
  Atomic creation of beds and a layout whilst ensuring the geometry of beds doesn't
  intersect with any other bed in the layout. Everything is done in a transaction
  so that if there's an issue, everything gets rolled back and nothing is inserted.

  NOTE: this is where I spent a lot of time. This is the limit of my Elixir skills.
  """
  def create_beds_and_layout(attrs) do
    # break up the attrs
    bed_attrs = Map.get(attrs, :beds)
    layout_attrs = Map.drop(attrs, [:beds])

    Repo.transaction(fn ->
      {:ok, layout} = create_layout(layout_attrs)
      layout = Repo.preload(layout, :beds)

      Enum.reduce_while(bed_attrs, {:ok, []}, fn attrs, {:ok, acc} ->
        # Add layout_id and build changeset
        attrs = Map.put(attrs, :layout_id, layout.id)
        changeset = Garden.Plans.Bed.changeset(%Garden.Plans.Bed{}, attrs)

        # check the changset is valid and doesn't overlap
        if changeset.valid? do
          # make the struct as database ready as we can get it
          {:ok, bed} = Ecto.Changeset.apply_action(changeset, :insert)

          if overlaps_any?(bed, layout.beds ++ acc) do
            # this is the important bit
            # there's any overlap so set the base error
            msg = "Bed at (#{bed.x}, #{bed.y}) with size #{bed.w}x#{bed.l} overlaps another bed"
            Repo.rollback(Ecto.Changeset.add_error(changeset, :base, msg))
          else
            # no overlaps and it is valid.
            case Repo.insert(changeset) do
              {:ok, inserted} ->
                # move on by returning :cont with {:ok and the accumulator}
                {:cont, {:ok, [inserted | acc]}}

              {:error, cs} ->
                # error inserting, so rollback and return changeset
                Repo.rollback({:error, cs})
            end
          end
        else
          # changeset was not valid
          Repo.rollback(changeset)
        end
      end)
      |> case do
        {:ok, beds} -> Enum.reverse(beds)
        error -> error
      end
    end)
  end

  defp overlaps_any?(new_bed, existing_beds) do
    Enum.any?(existing_beds, fn bed ->
      not (new_bed.x + new_bed.w < bed.x or
             new_bed.x > bed.x + bed.w or
             new_bed.y + new_bed.l < bed.y or
             new_bed.y > bed.y + bed.l)
    end)
  end

  @doc """
  Creates a plant
  """
  def create_plant(attrs) do
    benefits_from_ids = Map.get(attrs, :benefits_from, [])
    benefits_from = Repo.all(from p in Plant, where: p.id in ^benefits_from_ids)
    soil_ids = Map.get(attrs, :soils, [])
    soils = Repo.all(from(s in Soil, where: s.id in ^soil_ids))
    attrs = Map.drop(attrs, [:soil_ids])

    %Plant{}
    |> Plant.changeset(attrs)
    |> put_assoc(:soils, soils)
    |> put_assoc(:benefits_from, benefits_from)
    |> Repo.insert()
  end

  @doc """
  Creates soil
  """
  def create_soil(attrs) do
    %Soil{}
    |> Soil.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets the layout
  """
  def get_layout(id) do
    Repo.get(Layout, id)
  end

  @doc """
  Creates a layout.
  """
  def create_layout(attrs) do
    %Layout{}
    |> Layout.changeset(attrs)
    |> Repo.insert()
  end
end
