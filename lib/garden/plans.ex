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
