defmodule GardenWeb.API.PlantJSON do
  def index(%{plants: plants}) do
    Enum.map(plants, fn plant ->
      %{
        id: plant.id,
        name: plant.name,
        soils: Enum.map(plant.soils, &%{id: &1.id, name: &1.name}),
        benefits_from: Enum.map(plant.benefits_from, &%{id: &1.id, name: &1.name}),
        benefits_to: Enum.map(plant.benefits_to, &%{id: &1.id, name: &1.name})
      }
    end)
  end
end
