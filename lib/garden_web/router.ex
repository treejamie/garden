defmodule GardenWeb.Router do
  use GardenWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # if this is hosted on api.foo.com then /api makes no sense.
  # v1 scopes the APi to version, which is nice.
  scope "/v1", GardenWeb do
    pipe_through :api

    post("/layouts", GardenWeb.API.LayoutController, :create)
  end

end
