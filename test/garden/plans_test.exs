defmodule Garden.PlansTest do
  @moduledoc """
  Tests for the Plans context module
  """
  use Garden.DataCase

  alias Garden.Plans
  alias Garden.Plans.{Layout, Bed, Plant, Strategy, Plan}
  import Garden.PlansFixtures

  # TODO: organise this better
  describe "plan context tests" do
    test "create_layout_and_beds_atomically detects collision" do
      # make the background knowledge - just need soil for beds
      {:ok, soil} = Plans.create_soil(%{name: "loam"})

      # make the attrs
      attrs = %{
        "name" => "Kew",
        "beds" => [
          %{"soil_id" => soil.id, "x" => 1, "y" => 0, "l" => 2, "w" => 2},
          %{"soil_id" => soil.id, "x" => 2, "y" => 2, "l" => 2, "w" => 2}
        ]
      }

      # we sent a string for soil, but that didn't matter and now we have
      # one bed and a layout.
      {:error, _changeset} = Plans.create_layout_and_beds_atomically(attrs)

      # crucially however we have one layouts and one bed
      assert 0 == Repo.aggregate(Layout, :count, :id)
      assert 0 == Repo.aggregate(Bed, :count, :id)
    end

    test "create_layout_and_beds_atomically works with an actual soil.id" do
      # make the background knowledge - just need soil for beds
      {:ok, soil} = Plans.create_soil(%{name: "loam"})

      # make the attrs
      attrs = %{
        "name" => "Kew",
        "beds" => [
          %{"soil_id" => soil.id, "x" => 1, "y" => 0, "l" => 2, "w" => 2}
        ]
      }

      # we sent a string for soil, but that didn't matter and now we have
      # one bed and a layout.
      {:ok, _beds} = Plans.create_layout_and_beds_atomically(attrs)

      # crucially however we have one layouts and one bed
      assert 1 == Repo.aggregate(Layout, :count, :id)
      assert 1 == Repo.aggregate(Bed, :count, :id)
    end

    test "create_layout_and_beds_atomically translates a binary soil_id is into an actual soil.id" do
      # make the background knowledge - just need soil for beds
      {:ok, _soil} = Plans.create_soil(%{name: "loam"})

      # make the attrs
      attrs = %{
        "name" => "Kew",
        "beds" => [
          %{"soil_id" => "loam", "x" => 1, "y" => 0, "l" => 2, "w" => 2}
        ]
      }

      # we sent a string for soil, but that didn't matter and now we have
      # one bed and a layout.
      {:ok, _beds} = Plans.create_layout_and_beds_atomically(attrs)

      # crucially however we have one layouts and one bed
      assert 1 == Repo.aggregate(Layout, :count, :id)
      assert 1 == Repo.aggregate(Bed, :count, :id)
    end

    test "create_layout_and_beds_atomically returns error if soil_id is a string that doesn't fetch a soil" do
      # make the background knowledge - just need soil for beds
      {:ok, _soil} = Plans.create_soil(%{name: "loam"})

      # make the attrs
      attrs = %{
        "name" => "Kew",
        "beds" => [
          %{"soil_id" => "chalk", "x" => 1, "y" => 0, "l" => 2, "w" => 2}
        ]
      }

      # we have loam but we've sent chalk - soil_id has an error
      {:error, changeset} = Plans.create_layout_and_beds_atomically(attrs)
      refute changeset.valid?
      assert changeset.errors[:soil_id]

      # crucially however we have no layouts because rollback
      assert 0 == Repo.aggregate(Layout, :count, :id)
    end

    test "create_plants works as expected" do
      # make a soil
      soil = soil_fixture(%{name: "loam"})

      # make a plant with that soil and it should have one soil
      {:ok, tomato} = Plans.create_plant(%{name: "tomato", soils: [soil.id]})
      tomato = tomato |> Repo.preload(:soils)
      assert length(tomato.soils) == 1

      # great, now we can make another plant and do a benefits_from
      {:ok, celery} =
        Plans.create_plant(%{name: "celery", soils: [soil.id], benefits_from: [tomato.id]})

      celery = celery |> Repo.preload([:soils, :benefits_from])
      assert length(celery.benefits_from) == 1

      # and if we get tomato, we can see it gives benefits to celery
      tomato =
        Repo.get_by(Plant, name: "tomato") |> Repo.preload([:benefits_from, :benefits_to, :soils])

      assert "celery" in Enum.map(tomato.benefits_to, fn p -> p.name end)
    end

    test "get_strategy works as expected and preloads plans" do
      # build the universe: soil, plants, layout, bed
      {:ok, plant} = Plans.create_plant(%{name: "chilli"})
      {:ok, clay} = Plans.create_soil(%{name: "clay"})
      {:ok, layout} = Plans.create_layout(%{name: "The Blue Peter Garden"})

      {:ok, bed} =
        Plans.create_bed_in_layout(%{
          layout_id: layout.id,
          soil_id: clay.id,
          x: 0,
          y: 0,
          l: 2,
          w: 2
        })

      # make a strategy and plan
      {:ok, strategy} = Plans.create_strategy(%{name: "Quercus", layout_id: layout.id})

      {:ok, plan} =
        Plans.create_plan_in_strategy(%{
          strategy_id: strategy.id,
          bed_id: bed.id,
          area: 3.75,
          plant_id: plant.id
        })

      # get the strategy from context function and we have the strategy and preloaded plans
      s = Plans.get_strategy(strategy.id)
      assert plan.id == List.first(s.plans).id
    end

    test "list_strategies_for_layout" do
      # make a layout and give it two strategies
      {:ok, layout} = Plans.create_layout(%{name: "The Blue Peter Garden"})
      {:ok, _s1} = Plans.create_strategy(%{name: "Mullen", layout_id: layout.id})
      {:ok, _s2} = Plans.create_strategy(%{name: "Vallely", layout_id: layout.id})
      {:ok, _s3} = Plans.create_strategy(%{name: "Barbie", layout_id: layout.id})

      # now use context manager and we get back the
      strategies = Plans.list_strategies_for_layout(layout.id)
      assert 3 == Enum.count(strategies)
    end

    test "create_plan_in_strategy errors if plan area bigger than bed area" do
      # build the universe: soil, plants, layout, bed
      {:ok, plant} = Plans.create_plant(%{name: "chilli"})
      {:ok, clay} = Plans.create_soil(%{name: "clay"})
      {:ok, layout} = Plans.create_layout(%{name: "The Blue Peter Garden"})

      {:ok, bed} =
        Plans.create_bed_in_layout(%{
          layout_id: layout.id,
          soil_id: clay.id,
          x: 0,
          y: 0,
          l: 2,
          w: 2
        })

      {:ok, strategy} = Plans.create_strategy(%{name: "Avalokiteśvara", layout_id: layout.id})

      # now make the plan attrs and save it - plan area larger than bed
      plan_attrs = %{strategy_id: strategy.id, bed_id: bed.id, area: 4.01, plant_id: plant.id}

      # we get an error, changset is not valid and the error is in the right place
      {:error, changeset} = Plans.create_plan_in_strategy(plan_attrs)
      refute changeset.valid?
      assert changeset.errors[:area]
    end

    test "create_plan_in_strategy works as expected" do
      # build the universe: soil, plants, layout, bed
      {:ok, plant} = Plans.create_plant(%{name: "chilli"})
      {:ok, clay} = Plans.create_soil(%{name: "clay"})
      {:ok, layout} = Plans.create_layout(%{name: "The Blue Peter Garden"})

      {:ok, bed} =
        Plans.create_bed_in_layout(%{
          layout_id: layout.id,
          soil_id: clay.id,
          x: 0,
          y: 0,
          l: 2,
          w: 2
        })

      {:ok, strategy} = Plans.create_strategy(%{name: "Māra", layout_id: layout.id})

      # now make the plan attrs and save it - area on this one is less than bed.
      plan_attrs = %{strategy_id: strategy.id, bed_id: bed.id, area: 3.75, plant_id: plant.id}
      {:ok, plan} = Plans.create_plan_in_strategy(plan_attrs)

      # now get the plan and preload everything and check it's working as we expect
      plan = Repo.get(Plan, plan.id) |> Repo.preload([:bed, :plant, :strategy])
      assert plan.plant.id == plant.id
      assert plan.bed.id == bed.id
      assert plan.strategy.id == strategy.id
    end

    test "create_strategy works as expected" do
      # strategies need a plan
      {:ok, layout} = Plans.create_layout(%{name: "The Blue Peter Garden"})

      # build the stragegy_attrs
      strategy_attrs = %{
        layout_id: layout.id,
        name: "version one, bees.",
        description: "A plan maximised around bee activity"
      }

      # it saves and we have one in the database
      {:ok, _strategy} = Plans.create_strategy(strategy_attrs)
      assert 1 == Repo.aggregate(Strategy, :count, :id)
    end

    test "list_plants" do
      # we have no plants
      assert 0 == Enum.count(Plans.list_plants())

      # make plants
      {:ok, _tomato} = Plans.create_plant(%{name: "tomato"})
      {:ok, _celery} = Plans.create_plant(%{name: "celery"})
      {:ok, _basil} = Plans.create_plant(%{name: "basil"})

      # we have three plants
      assert 3 == Enum.count(Plans.list_plants())
    end

    test "get_plant - by name and id" do
      # make plant
      {:ok, plant} = Plans.create_plant(%{name: "chilli"})

      # now get it by id and name
      assert plant.id == Plans.get_plant(plant.id).id
      assert plant.id == Plans.get_plant(plant.name).id
    end

    test "list_soils" do
      # we have no soils
      assert 0 == Enum.count(Plans.list_soils())

      # make soils
      {:ok, _sand} = Plans.create_soil(%{name: "sand"})
      {:ok, _loam} = Plans.create_soil(%{name: "loam"})
      {:ok, _clay} = Plans.create_soil(%{name: "clay"})

      # we have three soils
      assert 3 == Enum.count(Plans.list_soils())
    end

    test "get_soil - by name or id" do
      # make soil
      {:ok, soil} = Plans.create_soil(%{name: "loam"})

      # now get it by id and name
      assert soil.id == Plans.get_soil(soil.id).id
      assert soil.id == Plans.get_soil(soil.name).id
    end

    # create bed for layout
    test "create_bed_in_layout handles invalid changesets" do
      # make the background knowledge - just need soil for beds
      {:ok, soil} = Plans.create_soil(%{name: "loam"})

      # make a layout
      {:ok, layout} = Plans.create_layout(%{name: "onroad"})

      # define bed attrs and make the bed in the layout
      b1_attrs = %{layout_id: layout.id, soil_id: soil.id, x: nil, y: 0, l: 2, w: 2}

      # bed won't save because invalid
      {:error, changeset} = Plans.create_bed_in_layout(b1_attrs)
      refute changeset.valid?
    end

    test "create_bed_in_layout works as expected" do
      # make the background knowledge - just need soil for beds
      {:ok, soil} = Plans.create_soil(%{name: "loam"})

      # make a layout
      {:ok, layout} = Plans.create_layout(%{name: "onroad"})

      # define bed attrs and make the bed in the layout
      b1_attrs = %{layout_id: layout.id, soil_id: soil.id, x: 0, y: 0, l: 2, w: 2}

      # make the bed for the layout and as there are no beds, it'll be saved
      {:ok, _bed} = Plans.create_bed_in_layout(b1_attrs)

      # define bed attrs for a second bed and collide the geometry
      b2_attrs = %{layout_id: layout.id, soil_id: soil.id, x: 1, y: 1, l: 2, w: 2}

      # nope
      {:error, changeset} = Plans.create_bed_in_layout(b2_attrs)
      refute changeset.valid?
    end

    test "get_beds_for_layout works as expected" do
      # do the background knowledge, but bypass context to
      # create the beds becasue we're just interested in ensuring
      # we get beds for layout.

      # make stuff
      {:ok, soil} = Plans.create_soil(%{name: "loam"})
      {:ok, layout} = Plans.create_layout(%{name: "onroad"})

      # bed attrs and backdoor creation
      [
        %{layout_id: layout.id, soil_id: soil.id, x: 0, y: 0, l: 2, w: 2},
        %{layout_id: layout.id, soil_id: soil.id, x: 2.1, y: 2.1, l: 2, w: 2}
      ]
      |> Enum.map(fn b ->
        %Bed{}
        |> Bed.changeset(b)
        |> Repo.insert!()
      end)

      # call the context function and we have two beds
      assert 2 == Enum.count(Plans.get_beds_for_layout(layout.id))
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
