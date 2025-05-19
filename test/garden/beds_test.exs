defmodule Garden.Plans.BedsTest do
  use Garden.DataCase
  alias Garden.Plans.Bed
  import Garden.PlansFixtures
  import Ecto.Changeset

  test "changeset calculates area" do
    layout = layout_fixture()
    attrs = %{w: 2, l: 3, x: 0, y: 0, layout_id: layout.id}
    # area is 6.0 becasue 2.0 * 3.0 == 6.0
    assert {:ok, 6.0} == Bed.changeset(%Bed{}, attrs) |> fetch_change(:area)
  end
end
