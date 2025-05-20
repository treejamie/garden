defmodule GardenWeb.API.LayoutControllerTests do
  use GardenWeb.ConnCase, async: true

  describe "creation tests" do

    defp layout_create_url, do: ~p"/v1/layout/"

    # create_layout_collinding_beds
    # create_layout_one_bed
    test "create_layout_no_beds", %{conn: conn} do
      # very minimal
      params = %{name: "A lovely layout"}

      # SEND IT!
      conn =
        post(conn, layout_create_url(), params)

      IO.inspect(conn)
    end
  end
end
