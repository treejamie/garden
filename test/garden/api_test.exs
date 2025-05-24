defmodule Garden.APITest do
  @moduledoc """
  Tests for the Plans context module
  """
  use Garden.DataCase

  alias Garden.API
  alias Garden.Plans
  # alias Garden.Repo
  # alias Garden.Plans.{Layout, Bed}

  defp valid_attrs do
    %{
      "name" => "Kew",
      "beds" => [
        %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2},
        %{"soil_id" => "chalk", "x" => 3, "y" => 3, "l" => 2, "w" => 2}
      ]
    }
  end

  test "resolve soils returns soil attrs as ids - happy path three soils, two types" do

    # universe build, two soils, a new build and new attrs_in
    {:ok, chalk} = Plans.create_soil(%{"name" => "chalk"})
    {:ok, loam} = Plans.create_soil(%{"name" => "loam"})
    loam_bed = %{"soil_id" => "loam", "x" => 5, "y" => 5, "l" => 2, "w" => 2}
    attrs_in = Map.update!(valid_attrs(), "beds", fn beds -> beds ++ [loam_bed] end)

    # we have clay soil and the id matches
    assert %{
      "name" => "Kew",
      "beds" => [
        %{"soil_id" => chalk.id, "x" => 1, "y" => 0, "l" => 2, "w" => 2},
        %{"soil_id" => chalk.id, "x" => 3, "y" => 3, "l" => 2, "w" => 2},
        %{"soil_id" => loam.id, "x" => 5, "y" => 5, "l" => 2, "w" => 2}
      ]
    } == API.resolve_soils(attrs_in)
  end



  test "resolve soils returns soil attrs as ids - happy path one soil type" do

    # universe build
    {:ok, soil} = Plans.create_soil(%{"name" => "chalk"})
    attrs_in = valid_attrs()

    # we have clay soil and the id matches
    assert %{
      "name" => "Kew",
      "beds" => [
        %{"soil_id" => soil.id, "x" => 1, "y" => 0, "l" => 2, "w" => 2},
        %{"soil_id" => soil.id, "x" => 3, "y" => 3, "l" => 2, "w" => 2}
      ]
    } == API.resolve_soils(attrs_in)
  end


  test "resolve_soils returns correclty updated attrs - fail path" do
    attrs_in = valid_attrs()

    # no soils, two nils
    assert %{
      "name" => "Kew",
      "beds" => [
        %{"soil_id" => nil, "x" => 1, "y" => 0, "l" => 2, "w" => 2},
        %{"soil_id" => nil, "x" => 3, "y" => 3, "l" => 2, "w" => 2}
      ]
    } == API.resolve_soils(attrs_in)
  end
end
