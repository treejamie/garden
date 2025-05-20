defmodule GardenWeb.API.LayoutControllerTests do
  use GardenWeb.ConnCase, async: true
  alias Garden.Plans
  alias Garden.Repo
  alias Garden.Plans.Layout
  alias Garden.Plans.Bed

  describe "POST /v1/layouts tests" do

    test "POST /v1/layouts create_layout_collinding_beds 422", %{conn: conn} do
      {:ok, _soil} = Plans.create_soil(%{name: "loam"})
      {:ok, _soil} = Plans.create_soil(%{name: "chalk"})

      # A layout and a bed
      params = %{
        beds: [
          %{soil_id: "chalk", l: 2, w: 2, x: 0, y: 0},
          %{soil_id: "loam", l: 3.0, w: 3.0, x: 1, y: 1}
        ],
        name: "Bob's Garden"
      }

      # post it and we get a layout, 422 status (:unprocessable_entity) and
      # a location header to where we can access it it if we wanted to.
      conn = post(conn, ~p"/v1/layouts", params)
      assert 422 == conn.status
      assert 0 == Repo.aggregate(Layout, :count, :id)
      assert 0 == Repo.aggregate(Bed, :count, :id)

      # geometry was the cause - inferred by base error. A little blunt, I know.
      assert json_response(conn, 422)["errors"]["base"]

    end

    test "POST /v1/layouts create_layout_one_bed", %{conn: conn} do
      {:ok, _soil} = Plans.create_soil(%{name: "loam"})
      {:ok, _soil} = Plans.create_soil(%{name: "chalk"})

      # A layout and a bed
      params = %{
        beds: [
          %{l: 1.8, soil_id: "chalk", w: 2.5, x: 0, y: 0},
          %{l: 3.0, soil_id: "loam", w: 3.0, x: 5, y: 3}
        ],
        name: "Bob's Garden"
      }

      # post it and we get a layout, 201 status (:created) and
      # a location header to where we can access it it if we wanted to
      conn = post(conn, ~p"/v1/layouts", params)
      assert 201 == conn.status
      [location] = get_resp_header(conn, "location")
      assert location =~ ~p"/v1/layouts"
      assert 1 == Repo.aggregate(Layout, :count, :id)
      assert 2 == Repo.aggregate(Bed, :count, :id)

    end

    test "POST /v1/layouts works as expected when creating one bed with no layout", %{conn: conn} do
      # very minimal
      params = %{name: "A lovely layout"}

      # post it and we get a layout, 201 status (:created) and
      # a location header to where we can access it it if we wanted to
      conn = post(conn, ~p"/v1/layouts", params)
      assert 201 == conn.status
      [location] = get_resp_header(conn, "location")
      assert location =~ ~p"/v1/layouts"
      assert 1 == Repo.aggregate(Layout, :count, :id)
      assert 1 == Repo.aggregate(Bed, :count, :id)

    end

    test "GET /v1/layouts/:id returns a json rendered layout with all associations", %{conn: conn} do
      # make a layout
      {:ok, layout} = Plans.create_layout(%{name: "Kew"})

      # get it and it was a 200 and we have the right id
      conn = get(conn, ~p"/v1/layouts/#{layout.id}")
      assert conn.status == 200
      assert Map.get(json_response(conn, 200), "id") == layout.id
    end
  end
end
