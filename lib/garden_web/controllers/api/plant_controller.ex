defmodule GardenWeb.API.PlantController do
  use GardenWeb, :controller
  alias Garden.Plans
  alias Garden.Repo

  def index(conn, _params) do
    plants =
      Plans.list_plants()
      |> Repo.preload([:benefits_from, :benefits_to, :soils])

    render(conn, :index, plants: plants)
  end
end
