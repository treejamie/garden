defmodule Garden.PlansTest do
  @moduledoc """
  Tests for the Plans context module
  """
  use Garden.DataCase
  import Ecto.Query

  alias Garden.Plans
  alias Garden.Plans.{Layout, Bed}
  import Garden.PlansFixtures

  describe "Basic checks" do
    test "create_beds_and_layout works as expected" do

      # make two beds where one intersects the other - error
      attrs = %{
        name: "layout 1",
        beds: [
          %{w: 2, l: 3, x: 2, y: 2},
          %{w: 2, l: 3, x: 0, y: 0}
        ]
      }
      # we get an error on base - no layouts, no beds
      {:error, changeset} = Plans.create_beds_and_layout(attrs)
      assert Keyword.get(changeset.errors, :base)
      assert 0 == Repo.aggregate(from(l in Layout), :count, :id)
      assert 0 == Repo.aggregate(from(b in Bed), :count, :id)

      # make two beds where one has invalid data - error
      attrs = %{
        name: "layout 1",
        beds: [
          %{w: 2, l: -1, x: 2, y: 2},
          %{w: 2, l: 3, x: 0, y: 0}
        ]
      }
      # we get an error on l
      {:error, changeset} = Plans.create_beds_and_layout(attrs)
      assert Keyword.get(changeset.errors, :l)
      assert 0 == Repo.aggregate(from(l in Layout), :count, :id)
      assert 0 == Repo.aggregate(from(b in Bed), :count, :id)


      # make two beds where neither intersects
      attrs = %{
        name: "layout 1",
        beds: [
          %{w: 2, l: 2, x: 2.1, y: 2.1},
          %{w: 2, l: 2, x: 0, y: 0}
        ]
      }
      {:ok, _beds} = Plans.create_beds_and_layout(attrs)
      assert 1 == Repo.aggregate(from(l in Layout), :count, :id)
      assert 2 == Repo.aggregate(from(b in Bed), :count, :id)

    end

    test "get_layout works as expected" do
      # this does not exist
      assert nil == Plans.get_layout(1_231_321)

      # this one does
      {:ok, layout} = Plans.create_layout(%{name: "foo layout"})
      refute is_nil(Plans.get_layout(layout.id))
    end

    test "create_layout works as expected" do
      # use the context directly
      attrs = %{
        name: "A wonderful layout"
      }

      {:ok, _layout} = Plans.create_layout(attrs)
      assert 1 == Repo.aggregate(Layout, :count, :id)

      # use the fixture
      layout_fixture()
      assert 2 == Repo.aggregate(Layout, :count, :id)
    end
  end
end
