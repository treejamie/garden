defmodule Garden.API do
  alias Garden.Plans
  alias Garden.Repo
  alias Garden.Plans.{Layout, Soil}

  @doc """
  Soil id may be a name or an id.
  Changeset handles errors: two function heads avoids db calls.
  """
  def get_soil_by_id_or_name(%{"soil_id" => identifier}) do
    Plans.get_soil(identifier)
  end

  def get_soil_by_id_or_name(_), do: nil

  @doc """
  Resolve any named soils in attrs to actual soil ids.
  """
  def resolve_soils(attrs) do
    # the value is used twice, so assign it once.
    beds_in = Map.get(attrs, "beds", [])

    # do the work.
    beds_out =
      beds_in
      |> Enum.map(&get_soil_by_id_or_name/1)
      |> Enum.zip(beds_in)
      |> Enum.map(fn {soil, bed} ->
          case soil do
            nil -> Map.put(bed, "soil_id", nil)
            %Soil{} = soil -> Map.put(bed, "soil_id", soil.id)
          end
      end)

    # update the attrs with the beds translated into ids.
    Map.put(attrs, "beds", beds_out)
  end

  # creates a layout with beds
  def create_layout_and_beds(attrs) do
    with attrs <- resolve_soils(attrs),
         changeset <- Layout.changeset_with_beds(%Layout{}, attrs),
         {:ok, layout} <- Repo.insert(changeset) do
      Repo.preload(layout, :beds)
    else
      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
