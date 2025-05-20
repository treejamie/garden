defmodule GardenWeb.API.LayoutJSON do
  def error(%{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    %{errors: errors}
  end

  def show(%{garden_layout: layout}) do
    %{
      id: layout.id,
      name: layout.name,
      beds: layout.beds
    }
  end
end
