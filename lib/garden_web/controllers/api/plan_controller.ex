defmodule GardenWeb.API.PlanController do
  use GardenWeb, :controller
  alias Garden.Plans
  alias Garden.Plan
  alias Garden.Repo

  def create(conn, _params) do
    render(conn, :create, plans: [])
  end
end
