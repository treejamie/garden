defmodule Garden.API do
  alias Garden.Plans

  def build_layout_attrs(attrs) do
    Map.drop(attrs, ["beds"])
  end

  def build_beds_attrs(attrs) do
    Map.get(attrs, "beds", [])
  end

  @doc """
  Soil id may be a name or an id
  """
  def get_soil_by_id_or_name(%{"soil_id" => identifier}) do
    case Plans.get_soil(identifier) do
      nil -> {:soil_error, :get_soil_by_id_or_name, identifier}
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
      {:soil_error, reason, id }  -> {:soil_error, reason, id }
      _ -> {:error, attrs}
    end
  end
end
