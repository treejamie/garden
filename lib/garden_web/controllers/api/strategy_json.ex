defmodule GardenWeb.API.StrategyJSON do
  def error(%{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    %{errors: errors}
  end

  def show(%{strategy: strategy}) do
    %{
      id: strategy.id,
      name: strategy.name,
      description: strategy.description,
      score: strategy.score,
      plans: strategy.plans
    }
  end
end
