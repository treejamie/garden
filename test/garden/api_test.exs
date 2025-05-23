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
    assert bed_attrs == %{"soil_id" => soil.id, "x" => 1, "y" => 0, "l" => 2, "w" => 2, "layout_id" => 2}

    IO.inspect(bed_attrs)
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
