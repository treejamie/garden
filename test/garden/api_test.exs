defmodule Garden.APITest do
  @moduledoc """
  Tests for the Plans context module
  """
  use Garden.DataCase

  alias Garden.API
  alias Garden.Plans

  @tag :sword
  test "build_beds_attrs" do
    # make the background knowledge - just need soil for beds
    {:ok, _soil} = Plans.create_soil(%{name: "loam"})

    # make the attrs
    attrs = %{
      "name" => "Kew",
      "beds" => [
        %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2}
      ]
    }

    # make the attrs for the layout and we get back an expected map
    beds_attrs = API.build_beds_attrs(attrs)

    assert [%{"l" => 2, "soil_id" => "chalk", "w" => 2, "x" => 1, "y" => 0}] =
             beds_attrs
  end

  @tag :sword
  test "build_layout_attrs" do
    # make the background knowledge - just need soil for beds
    {:ok, _soil} = Plans.create_soil(%{name: "loam"})

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
