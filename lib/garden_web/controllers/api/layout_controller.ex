defmodule GardenWeb.API.LayoutController do
  use GardenWeb, :controller
  alias Garden.Plans

  def create(conn, params) do
    case Plan.create_layout(params) do
      {:ok, layout } ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/v1/gardens/#{layout.id}")
        |> render(:show, layout: layout)
    end
    render(conn)
  end

end
