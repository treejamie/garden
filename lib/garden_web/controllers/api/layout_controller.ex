defmodule GardenWeb.API.LayoutController do
  use GardenWeb, :controller
  alias Garden.Plans
  alias Garden.Repo

  def list(conn, _params) do
    layouts = Plans.get_layouts()
    render(conn, :list, garden_layouts: Repo.preload(layouts, [:beds, :strategies]))
  end

  def create(conn, params) do
    case Plans.create_layout_and_beds_atomically(params) do
      {:ok, layout} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/v1/layouts/#{layout.id}")
        |> render(:show, garden_layout: Repo.preload(layout, [:beds]))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    # it was at this point I realised I'd modelled everything and used a reserved word.
    case Plans.get_layout(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Layout not found"})

      layout ->
        conn
        |> render(:show, garden_layout: Repo.preload(layout, [:beds]))
    end
  end
end
