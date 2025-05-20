defmodule GardenWeb.API.LayoutControllerTests do
  use GardenWeb.ConnCase, async: true
  alias Garden.Plans

  describe "creation tests" do

    # create_layout_collinding_beds
    # create_layout_one_bed
    test "POST /v1/layouts works as expected when creating one bed with no layout", %{conn: conn} do
      # very minimal
      params = %{name: "A lovely layout"}

      # SEND IT!
      conn = post(conn, ~p"/v1/layouts", params)
      assert conn.status == 201
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
