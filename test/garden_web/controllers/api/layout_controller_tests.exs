defmodule GardenWeb.API.LayoutControllerTests do
  use GardenWeb.ConnCase, async: true
  alias Garden.Plans

  describe "POST /v1/layouts tests" do
    # create_layout_collinding_beds
    test "POST /v1/layouts create_layout_one_bed", %{conn: conn} do
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
