defmodule GardenWeb.Router do
  use GardenWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # if this is hosted on api.foo.com then /api makes no sense.
  # v1 scopes the APi to version, which is nice.
  scope "/v1", GardenWeb do
    pipe_through :api

    post("/strategies", API.StrategyController, :create)
    get("/strategies/:id", API.StrategyController, :show)

    post("/layouts", API.LayoutController, :create)
    get("/layouts/:id", API.LayoutController, :show)

    # endpoints for background knowledge
    get("/soils", API.SoilController, :index)
  end

end
