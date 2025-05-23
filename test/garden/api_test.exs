defmodule Garden.APITest do
  @moduledoc """
  Tests for the Plans context module
  """
  use Garden.DataCase

  alias Garden.API
  alias Garden.Plans

  @tag :sword
  test "build_bed_attrs - happy path" do
    # make the background knowledge - just need soil for beds
    {:ok, soil} = Plans.create_soil(%{name: "chalk"})

    # make the attrs
    attrs = %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2}
    layout_id = 2

    # make the attrs and we get back an expected map with a soil id
    {:ok, bed_attrs} = API.build_bed_attrs(attrs, layout_id)

    assert bed_attrs == %{
             "soil_id" => soil.id,
             "x" => 1,
             "y" => 0,
             "l" => 2,
             "w" => 2,
             "layout_id" => 2
           }
  end

  @tag :sword
  test "get_soil_by_id or name - fail path" do
    # there is no soil - {:error, :soil_not_found}
    assert {:error, :soil_not_found} = API.get_soil_by_id_or_name(%{"soil_id" => "loam"})

    # there is not the soil you're looking for -
    {:ok, _soil} = Plans.create_soil(%{name: "chalk"})
    assert {:error, :soil_not_found} = API.get_soil_by_id_or_name(%{"soil_id" => "clay"})
  end

  @tag :sword
  test "get_soil_by_id or name - happy path" do
    # make the soil
    {:ok, soil} = Plans.create_soil(%{name: "chalk"})

    # get it by id and work as expected
    {:ok, soil_result} = API.get_soil_by_id_or_name(%{"soil_id" => soil.id})
    assert soil_result == soil

    # get it by name and work as expected
    {:ok, soil_result} = API.get_soil_by_id_or_name(%{"soil_id" => soil.name})
    assert soil_result == soil
  end

  @tag :sword
  test "build_beds_attrs  - happy path" do
    # make the background knowledge - just need soil for beds
    # {:ok, _soil} = Plans.create_soil(%{name: "chalk"})

    # make the attrs
    attrs = %{
      "name" => "Kew",
      "beds" => [
        %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2},
        %{"soil_id" => "chalk", "x" => 3, "y" => 3, "l" => 2, "w" => 2}
      ]
    }

    # make the attrs for the beds and we get back an expected map
    beds_attrs = API.build_beds_attrs(attrs)

    assert [
             %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2},
             %{"soil_id" => "chalk", "x" => 3, "y" => 3, "l" => 2, "w" => 2}
           ] = beds_attrs
  end

  @tag :sword
  test "build_layout_attrs - happy path" do
    # make the background knowledge - just need soil for beds
    # {:ok, _soil} = Plans.create_soil(%{name: "loam"})

    # make the attrs
    attrs = %{
      "name" => "Kew",
      "beds" => [
        %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2}
      ]
    }

    # make the attrs for the layout and we get back an expected map
    layout_attrs = API.build_layout_attrs(attrs)
    assert %{"name" => "Kew"} == layout_attrs
  end
end
