defmodule GardenWeb.Router do
  use GardenWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # if this is hosted on api.foo.com then /api makes no sense.
  # v1 scopes the API to version, which is nice.
  scope "/v1", GardenWeb do
    pipe_through(:api)

    # core endpoints
    post("/strategies", API.StrategyController, :create)
    get("/strategies/:id", API.StrategyController, :show)

    # supplemental endpoints
    post("/layouts", API.LayoutController, :create)
    get("/layouts", API.LayoutController, :list)
    get("/layouts/:id", API.LayoutController, :show)
    get("/soils", API.SoilController, :index)
    get("/plants", API.PlantController, :index)
  end
end
