defmodule Garden.Plans do
  @moduledoc """
  The Plan context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Garden.Repo

  alias Garden.Plans.{Layout, Soil, Plant, Bed, Strategy, Plan}

  @doc """
  Gets a strategy for a given id with plans preloaded
  """
  def get_strategy(id) do
    Repo.get(Strategy, id) |> Repo.preload(:plans)
  end

  @doc """
  Lists all strategies for a layout
  """
  def list_strategies_for_layout(layout_id) do
    from(s in Strategy,
      where: s.layout_id == ^layout_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a plan in a strategy.
  """
  def create_plan_in_strategy(attrs) do
    changeset =
      %Plan{}
      |> Plan.changeset(attrs)

    case changeset.valid? do
      true ->
        check_bed_area_equals_or_gt_plan(changeset)
        |> Repo.insert()

      false ->
        # it won't work, but be consistent with other functions
        Repo.insert(changeset)
    end
  end

  def check_bed_area_equals_or_gt_plan(changeset) do
    # get the bed and area
    bed = get_field(changeset, :bed_id) |> get_bed()
    plan_area = get_field(changeset, :area)

    if plan_area > bed.area do
      msg = "The area of the plan exceeds the bed area of #{bed.area}"
      add_error(changeset, :area, msg)
    else
      changeset
    end
  end

  @doc """
  Gets a bed for a given id
  """
  def get_bed(id) do
    Repo.get(Bed, id)
  end

  @doc """
  Creates a strategy
  """
  def create_strategy(attrs) do
    %Strategy{}
    |> Strategy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all plants
  """
  def list_plants() do
    Repo.all(Plant)
  end

  @doc """
  Gets plant by soil or id
  """
  def get_plant(id) when is_binary(id) do
    Repo.get_by(Plant, name: id)
  end

  def get_plant(id) do
    Repo.get(Plant, id)
  end

  @doc """
  Lists all soils
  """
  def list_soils() do
    Repo.all(Soil)
  end

  @doc """
  Gets soil by name or id
  """
  def get_soil(id) when is_binary(id) do
    Repo.get_by(Soil, name: id)
  end

  def get_soil(id) do
    Repo.get(Soil, id)
  end

  @doc """
  Create a layout and beds atomically and if there are
  any errors, rollback so that we leave the data in good shape.

  Dear reader - this is the edge of my current knowledge. I look
  forward to going beyond this in the near future.

  This works, but I'm holding my nose a bit. It was lucky for me
  that Repo.rollback acts like a raise.  Despite the smell, it
  was important that I got this bit working. Sometimes, that's how
  it goes.
  """
  def create_layout_and_beds_atomically(attrs) do
    # get the attributes
    layout_attrs = Map.drop(attrs, [:beds])
    beds_attrs = Map.get(attrs, :beds)

    # open transaction
    Repo.transaction(fn ->
      # if layout fails, abort and rollback
      layout =
        case create_layout(layout_attrs) do
          {:ok, layout} ->
            layout

          {:error, changeset} ->
            Repo.rollback(changeset)
        end

      # beds could be one or more, so it's an enumeration. There are other tools
      # that would fit better here reduce_while, reduce etc, but I wanted to do
      # it with the tools I know to honestly show you what you'd be hiring.
      beds =
        Enum.map(beds_attrs, fn attrs ->

          # put layout_id into the attrs
          attrs = Map.put(attrs, :layout_id, layout.id)

          # soil could be a name and that won't save so replace any binary soil_id
          # with an defacto soil id. This is another database intensive operation
          # that I would monitor in a production environment
          soil_from_attrs = Map.get(attrs, :soil_id, nil)

          soil_id =
            if is_binary(soil_from_attrs) do
              case get_soil(soil_from_attrs) do
                nil ->
                  # return a changeset with the error
                  Repo.rollback(
                    add_error(
                      Bed.changeset(%Bed{}, attrs),
                      :soil_id,
                      "#{soil_from_attrs} is not a known soil type"
                    )
                  )
                soil -> soil.id
              end
            else
              get_soil(soil_from_attrs).id
            end


          # update attrs with soil id
          attrs = Map.put(attrs, :soil_id, soil_id)

          # now after all that pollava we can just do the thing
          case create_bed_in_layout(attrs) do
            {:ok, bed} ->
              bed

            {:error, changeset} ->
              Repo.rollback(changeset)
          end
        end)

      # and done...
      beds
    end)
  end

  @doc """
  Creates a bed in a given layout.

  Beds must not collide with any existing beds in that layout.
  """
  def create_bed_in_layout(attrs) do
    # make the changeset but don't do geometry unless changeset.valid? is true
    changeset =
      %Bed{}
      |> Bed.changeset(attrs)

    case changeset.valid? do
      true ->
        check_geometry(changeset)
        |> Repo.insert()

      false ->
        # it won't work, but be consistent with other functions
        Repo.insert(changeset)
    end
  end

  @doc """
  Ensures bed geometry doesn't intersect with any other geometry
  """
  def check_geometry(changeset) do
    # make a bed
    bed = Ecto.Changeset.apply_action!(changeset, :insert)

    # this will always be safe to get
    beds =
      get_field(changeset, :layout_id)
      |> get_beds_for_layout()

    # check geometry
    if overlaps_any?(bed, beds) do
      msg = "Bed at (#{bed.x}, #{bed.y}) with size #{bed.w}x#{bed.l} overlaps another bed"
      Ecto.Changeset.add_error(changeset, :base, msg)
    else
      changeset
    end
  end

  @doc """
  Returns beds for a given layout
  """
  def get_beds_for_layout(layout_id) do
    from(b in Bed,
      where: b.layout_id == ^layout_id
    )
    |> Repo.all()
  end

  @doc """
  Detects overlap on a new bed against existing beds.
  Currently uses primitive collision detection (AABB) and doesn't handle
  touching very well.
  """
  def overlaps_any?(new_bed, existing_beds) do
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
    benefits_from = Repo.all(from(p in Plant, where: p.id in ^benefits_from_ids))
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
