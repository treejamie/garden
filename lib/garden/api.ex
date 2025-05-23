defmodule Garden.API do



  def build_layout_attrs(attrs) do
    Map.drop(attrs, ["beds"])
  end

  def build_beds_attrs(attrs) do
    beds_attrs = Map.get(attrs, "beds", [])
  end

end
