defmodule GardenWeb.API.StrategyController do
  use GardenWeb, :controller
  alias Garden.Plans
  # alias Garden.Plan
  alias Garden.Repo

  def create(conn, params) do
    case Plans.create_strategy_and_plans_atomically(params) do
      {:ok, strategy} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/v1/strategies/#{strategy.id}")
        |> render(:show, strategy: Repo.preload(strategy, [:layout, plans: [:bed, :plant]]))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
      end

  end

  def show(conn, %{"id" => id}) do
    case Plans.get_strategy(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Strategy not found"})
      strategy ->
        conn
        |> render(:show, strategy: Repo.preload(strategy, [:layout, [plans: [:bed, :plant]]]))
    end
  end
end
