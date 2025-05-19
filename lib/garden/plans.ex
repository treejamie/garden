defmodule Garden.Plans do
  @moduledoc """
  The Plan context.
  """

  import Ecto.Query, warn: false

  alias Garden.Repo
  alias Garden.Plans.Layout

  @doc """
  Create a layout
  """
  def create_layout(attrs \\ %{}) do
    %Layout{}
    |> Layout.changeset(attrs)
    |> Repo.insert()
  end
end
