defmodule Garden.PlansTest do
  @moduledoc """
  Tests for the Plans context module
  """
  use Garden.DataCase

  alias Garden.Plans
  alias Garden.Plans.Layout
  import Garden.PlansFixtures

  describe "Layouts" do

    test "create_layout works as expected" do

      # use the context directly
      attrs = %{name: "A wonderful layout"}
      {:ok, _layout} = Plans.create_layout(attrs)
      assert 1 == Repo.aggregate(Layout, :count, :id)

      # use the fixture
      layout_fixture()
      assert 2 == Repo.aggregate(Layout, :count, :id)


    end
  end
end
