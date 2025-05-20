defmodule GardenWeb.API.StrategyControllerTests do
  use GardenWeb.ConnCase, async: true
  alias Garden.Plans
  alias Garden.Repo
  alias Garden.Plans.{Strategy, Plan}

  describe "POST /strategies tests for creating plans" do

    test "422 when strategy is created with a plan ", %{conn: conn} do
      # build universe
      {:ok, soil} = Plans.create_soil(%{name: "clay"})
      {:ok, _plant} = Plans.create_plant(%{name: "tomato", soils: [soil.id]})
      {:ok, layout} = Plans.create_layout(%{name: "onroad"})

      {:ok, bed} =
        Plans.create_bed_in_layout(%{
          layout_id: layout.id,
          soil_id: soil.id,
          x: 0,
          y: 0,
          l: 2,
          w: 2
        })

      # build params
      params = %{
        "name" => "Bobs Super Planting Plan",
        "layout_id" => layout.id,
        "description" => "arrgh man, yiv never seen mahters lyke it",  # geordie grandfather
        "plans" => [
          %{"bed_id" => bed.id, "plant_id" => "tomato", "area" => 3.2}
        ]
      }

      # set it, 201
      conn = post(conn, ~p"/v1/strategies", params)
      assert conn.status == 201

      # one stategy and one plans
      assert 1 == Repo.aggregate(Strategy, :count, :id)
      assert 1 == Repo.aggregate(Plan, :count, :id)
    end

    test "201 when strategy is created with a plan that uses strings for plant_id", %{conn: conn} do
      # build universe
      {:ok, soil} = Plans.create_soil(%{name: "clay"})
      {:ok, _plant} = Plans.create_plant(%{name: "tomato", soils: [soil.id]})
      {:ok, layout} = Plans.create_layout(%{name: "onroad"})

      {:ok, bed} =
        Plans.create_bed_in_layout(%{
          layout_id: layout.id,
          soil_id: soil.id,
          x: 0,
          y: 0,
          l: 2,
          w: 2
        })

      # build params
      params = %{
        "name" => "Bobs Super Planting Plan",
        "layout_id" => layout.id,
        "description" => "arrgh man, yiv never seen mahters lyke it",  # geordie grandfather
        "plans" => [
          %{"bed_id" => bed.id, "plant_id" => "tomato", "area" => 3.2}
        ]
      }

      # set it, 201
      conn = post(conn, ~p"/v1/strategies", params)
      assert conn.status == 201

      # one stategy and one plans
      assert 1 == Repo.aggregate(Strategy, :count, :id)
      assert 1 == Repo.aggregate(Plan, :count, :id)
    end

    test "201 when strategy is created with a plan", %{conn: conn} do
      # build universe
      {:ok, soil} = Plans.create_soil(%{name: "clay"})
      {:ok, plant} = Plans.create_plant(%{name: "tomato", soils: [soil.id]})
      {:ok, layout} = Plans.create_layout(%{name: "onroad"})

      {:ok, bed} =
        Plans.create_bed_in_layout(%{
          layout_id: layout.id,
          soil_id: soil.id,
          x: 0,
          y: 0,
          l: 2,
          w: 2
        })

      # build params
      params = %{
        "name" => "Bobs Super Planting Plan",
        "layout_id" => layout.id,
        "description" => "arrgh man, yiv never seen mahters lyke it",  # geordie grandfather
        "plans" => [
          %{"bed_id" => bed.id, "plant_id" => plant.id, "area" => 3.2}
        ]
      }

      # set it, 201
      conn = post(conn, ~p"/v1/strategies", params)
      assert conn.status == 201

      # one stategy and one plans
      assert 1 == Repo.aggregate(Strategy, :count, :id)
      assert 1 == Repo.aggregate(Plan, :count, :id)
    end

    test "422 if invalid data sent to endpoint", %{conn: conn} do
      # build silly data
      params = %{"foo" => "bar"}

      # send it, 422
      conn = post(conn, ~p"/v1/strategies", params)
      assert conn.status == 422

      # no stategies or plans
      assert 0 == Repo.aggregate(Strategy, :count, :id)
      assert 0 == Repo.aggregate(Plan, :count, :id)
    end
  end

  describe "GET /strategies for accessing plans" do
    test "200 when viewing a strategy", %{conn: conn} do
      # need a layout
      {:ok, layout} = Plans.create_layout(%{"name" => "L"})

      # make a strategy
      {:ok, strategy} =
        Plans.create_strategy(%{
          "name" => "One",
          "description" => "a winner",
          "layout_id" => layout.id
        })

      # get the page and it was 200 and contains our strategy
      conn = get(conn, ~p"/v1/strategies/#{strategy.id}")
      assert conn.status == 200
      assert json_response(conn, 200)["id"] == strategy.id
    end
  end
end
