defmodule Garden.APITest do
  @moduledoc """
  Tests for the Plans context module
  """
  use Garden.DataCase

  alias Garden.API
  alias Garden.Plans
  alias Garden.Repo
  alias Garden.Plans.{Layout, Bed}

  describe "create_layout_and_beds_atomically" do
    defp valid_attrs do
      %{
        "name" => "Kew",
        "beds" => [
          %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2},
          %{"soil_id" => "chalk", "x" => 3, "y" => 3, "l" => 2, "w" => 2}
        ]
      }
    end

    @tag :skip #:sword_x
    test "create_layout_and_beds_atomically happy path" do
      # send the valid attributes and we get the layout with the beds preloaded
      API.create_layout_and_beds_atomically(valid_attrs()) |> IO.inspect(label: "test")
    end

    @tag :skip #:sword
    test "create_beds - happy path" do
      # get layout attrs, beds_attrs and build a layout
      {:ok, l_attrs} = API.build_layout_attrs(valid_attrs())
      {:ok, layout} = API.create_layout(l_attrs)
      {:ok, beds_attrs} = API.build_beds_attrs(valid_attrs())
      #
      #
      # YOU WERE HERE
      # create beds neds to call Enum.map(beds_attrs, fn CRWEATE_BED_ATTRS)bed_attrs
      # but it was 10:30 and you needd to get to teh woodland.

      # no beds
      assert 0 == Repo.aggregate(Bed, :count, :id)

      # build the beds
      {:ok, _beds} = API.create_beds(beds_attrs)

      # two beds
      assert 2 == Repo.aggregate(Bed, :count, :id)
    end

    @tag :sword
    test "create_layout - happy path" do
      # attrs
      attrs = %{"name" => "testing"}

      # no layouts
      assert 0 == Repo.aggregate(Layout, :count, :id)

      # success
      {:ok, _layout} = API.create_layout(attrs)

      # one layout
      assert 1 == Repo.aggregate(Layout, :count, :id)
    end

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
    test "get_soil_by_id or name - sad path" do
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
    test "build_beds_attrs  - sad path" do
      # no key results in an error
      assert {:error, :build_beds_attrs} == API.build_beds_attrs(%{})
    end

    @tag :sword
    test "build_beds_attrs  - happy path" do
      # make the attrs for the beds and we get back an expected map
      beds_attrs = API.build_beds_attrs(valid_attrs())

      assert {:ok,
              [
                %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2},
                %{"soil_id" => "chalk", "x" => 3, "y" => 3, "l" => 2, "w" => 2}
              ]} = beds_attrs
    end

    @tag :sword
    test "build_layout_attrs - sad path" do
      #  no key results in an error
      assert {:error, :build_layout_attrs} = API.build_layout_attrs(%{})
    end

    @tag :sword
    test "build_layout_attrs - happy path" do
      # make the attrs for the layout and we get back an expected map
      layout_attrs = API.build_layout_attrs(valid_attrs())
      assert {:ok, %{"name" => "Kew"}} == layout_attrs
    end
  end
end
