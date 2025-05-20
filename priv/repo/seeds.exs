# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Garden.Repo.insert!(%Garden.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Garden.Plans
alias Garden.Repo
alias Garden.Plans.Plant

# read in the JSON
bgknowledge_path = Path.join([File.cwd!(), "priv/background-knowledge.json"])

json =
  File.read!(bgknowledge_path)
  |> Jason.decode!()

# I could do this all in one swoop, but I"m going for quick and readable

# on a first pass, do the plants name, come back to benefits from later
# preload all relationships so we can put_assoc onto everything in next passes
plants =
  json
  |> Enum.map(fn %{"name" => name} ->
    plant =
      case Plans.get_plant(name) do
        nil ->
          Plans.create_plant(%{name: name})

        plant ->
          plant
      end
  end)

soils =
  json
  |> Enum.map(fn %{"soil_types" => soils} ->
    # soils is a list of soils, so Enum.map again
    soil =
      Enum.map(soils, fn name ->
        case Plans.get_soil(name) do
          nil ->
            Plans.create_soil(%{name: name})

          soil ->
            soil
        end
      end)
  end)

# and second pass now that everything is created and we can reliably set the assoc's
plants =
  json
  |> Enum.map(fn %{"name" => name, "soil_types" => soil_types, "benefits_from" => benefits_from} ->
    # get the plany by name and load up the associations
    plant =
      Plans.get_plant(name)
      |> Repo.preload([:benefits_from, :benefits_to, :soils])

    benefits_from =
      Enum.map(benefits_from, &Plans.get_plant/1)
      |> Enum.reject(&is_nil/1)

    # no context function for this one, so go straight to the repo
    plant =
      plant
      |> Plant.changeset(%{})
      |> Ecto.Changeset.put_assoc(:benefits_from, benefits_from)
      |> Repo.update!()

    IO.inspect(benefits_from)
  end)
