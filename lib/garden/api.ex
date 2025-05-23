defmodule Garden.API do
  alias Garden.Plans
  alias Garden.Repo




 def atomically_insert(insert_fn, attrs) do
    Repo.transaction(fn ->
      case insert_fn.(attrs) do
        {:ok, schema_struct} -> {:ok, schema_struct}
        {:error, error} -> Repo.rollback( {:error, error})
      end
    end)
  end


  @doc """
  Builds attrs for a layout from a supplied map
  """
  def build_layout_attrs(attrs) do
    case Map.has_key?(attrs, "name") do
      true -> {:ok, Map.drop(attrs, ["beds"])}
      false -> {:error, :build_layout_attrs}
    end
  end

  @doc """
  Builds attrs for a list of beds from a supplied map
  """

  def build_beds_attrs(attrs) do
    case Map.has_key?(attrs, "beds") do
      true -> {:ok, Map.get(attrs, "beds", [])}
      false -> {:error, :build_beds_attrs}
    end
  end

  @doc """
  Soil id may be a name or an id
  """
  def get_soil_by_id_or_name(%{"soil_id" => identifier}) do
    case Plans.get_soil(identifier) do
      nil -> {:error, :soil_not_found}
      soil -> {:ok, soil}
    end
  end
  def get_soil_by_id_or_name(identifier), do: {:soil_error, identifier}

  @doc """
  Builds bed attrs with a given layout id
  """
  def build_bed_attrs(attrs, layout_id) do
    with attrs <- Map.put(attrs, "layout_id", layout_id),
         {:ok, soil} <- get_soil_by_id_or_name(attrs),
         attrs <- Map.put(attrs, "soil_id", soil.id) do
      {:ok, attrs}
    else
      {:error, :build_beds_attrs} ->
        {:error, "cannot build beds - key 'beds' not found #{attrs}"}

      {:error, :build_layout_attrs} ->
        {:error, "cannot build layout - key 'name' name not found #{attrs}"}

      {:error, :soil_not_found} ->
        {:error, "soil type not found in #{attrs}"}

      _ ->
        {:error, attrs}
    end
  end

  def create_beds(beds_attrs) do
    # make the beds
    beds =
      Enum.map(beds_attrs, fn bed_attrs ->
          case Plans.create_bed_in_layout(bed_attrs) do
            {:ok, bed} -> bed
            {:error, changeset} ->  {:error, changeset}
          end
      end)
    beds |> IO.inspect(beds)
    # all or nothing so ensure they all were :ok

  end

  def create_layout(attrs) do
    case Plans.create_layout(attrs) do
      {:error, changeset} -> {:create_layout_error, changeset}
      {:ok, layout} -> {:ok, layout}
    end
  end



  def create_layout_and_beds(attrs) do
    with {:ok, layout_attrs} <- build_layout_attrs(attrs),
         {:ok, build_beds_attrs} <- build_beds_attrs(attrs),
         {:ok, layout} <- create_layout(layout_attrs),
         {:ok, beds} <- create_beds(build_beds_attrs) do
      Repo.preload(layout, :beds)
    else
      {:error, :layout_attrs_error} ->
        {:error, "layout attrs could not be build from #{attrs}"}
      _ ->
        :foo
    end
  end
end
