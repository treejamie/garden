defmodule GardenWeb.API.SoilController do
  use GardenWeb, :controller
  alias Garden.Plans
  alias Garden.Repo

  def index(conn, _params) do
    soils =
      Plans.list_soils()
      |> Repo.preload([:plants])

    render(conn, :index, soils: soils)
  end
end
