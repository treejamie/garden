defmodule Garden.PlansFixtures do

  alias Garden.Plans


  @doc """
  Generate a layout
  """
  def layout_fixture(attrs \\ %{}) do
    {:ok, layout} =
      attrs
      |> Enum.into(%{
        name: "The default layout name"
      })
      |> Plans.create_layout()
    layout
  end
end
