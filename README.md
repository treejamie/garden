*Interviewers*: 👋 Hello, I'm Jamie and look forward to discussing my work with you. Normally I'd run my readmes through an LLM to make them less wordy and less me, but in this case I've left them as is. Forgive any typos. It's semi-coversationally and is not how I would normally write a readme. An example of how I would normally approach a readme can be found [here][0] and [here][1]. Ok, that being said, on with the show...

There was a 3-4 hour time limit but in total I likley spent about 8-10 hours on it over the course of 20-21st May 2025. I did [tag the state of the application at the time limit][2]. What you see here is the final output for my submission which will also be tagged, but I cannot link that until I've written this. Circular dependancy 😆.

Also, whilst you may be looking at the code only, I took some effort to show how I'd use [Github][6]. I setup issues and made [PR's against them][4]. I also [setup a CI pipeline][5] at the start of the challenge. I thought that was worth pointing out incase it is missed. Normally I delete feature branches once I've squash merged them into main, but I have left them intact in case you want to go poking things with sticks!

One more thing. The spec on the challenge supplied CSV and said it was ok to change the datafiles, so I took a liberty and as JSON was already the format for the background-knowledge, I figured it'd be ok as the main format for using the API. After all, it returns JSON so it made more sense for it to accept JSON.

Anyway...

-----------------

# Garden

Garden is a response to a pre-interview challenge. It's an exercise, not an expression of professional intent. 

## Experience

The command line is how the user will interface with the API (_or maybe postman if that's how you roll_).

There should be three distinct stages from starting to getting a plan.

1. Create the layout with the beds and data about the beds. 
2. Create the plans for each bed. 
3. Query for a score for their plan.



## Requirements

This application was built using the below versions. It would likley work on other versions and if this was anything other than a demo, I'd give a list of full compatibility and ensure they were added into the CI tests.

* Phoenix - 1.7.21
* Elixir - 1.18.3
* Erlang - 27.3.4
* Postgres - 17.5

## Installation

1. `git clone git@github.com:treejamie/garden.git`
2. `cd garden`
3.  **asdf users only**: `asdf install`
4. `mix deps.get && mix.compile`
5. `mix setup` (_creates databases and imports background-knowledge_)
6. `mix phx.server` or `iex -S mix phx.server` (_project has a .iex.exs file to make iex sessions joyful with a preconfigured environment_) 

If you're using postman, you can also optionally use the [supplied postman collection][3]. 

## Creating Plans

For the second part I cannot give you completed "copy and paste" example because the ids requiire

### 1. Layouts and Beds

Before there can be a strategy with plans for each bed, there has to be a layout with beds. Let's build that first and as this is the first thing you're creating, you can use the following command line example to get you started.

This is for Bob's garden and it will succeed.

```shell
curl -X POST http://localhost:4000/v1/layouts \
  -H "Content-Type: Application/json" \
  --data-binary @priv/example-garden.json
```

That will respond with a bunch of JSON. I have expanded it through jq for clarity.
```json
{
  "id": 16,
  "name": "Garden of Bob",
  "beds": [
    { "id": 12, "x": 0.0, "y": 0.0, "w": 2.5, "l": 1.8, "area": 4.5, "soil_id": 1},
    { "id": 13, "x": 5.0, "y": 3.0, "w": 3.0, "l": 3.0, "area": 9.0, "soil_id": 2}
  ]
}
```

To experience failure, you can use this command. It fails.

```shell
curl -X POST http://localhost:4000/v1/layouts \
  -H "Content-Type: Application/json" \
  --data-binary @priv/example-garden-fail.json
```

And it fails because beds intersect

```json
{
  "errors": {
    "base": [
      "Bed at (1.0, 1.0) with size 3.0x3.0 overlaps another bed"
    ]
  }
}
```

It's worth noting that I mindfully spent time making these endpoints atomic and encased all database inserts in a transaction. So in the case of the latter example, even though the layout was created (_and it had to be to get the layout_id_) the beds collided and so the transaction was rolled back. I thought it was worth doing that because these are the kinds of considerations a framework cannot understand. You're still responsible for your data.


### 2. Strategies and Plans

I'd love to give you copy and paste examples, because everyone loves a bit of click'n'fire however at this stage you're going to need to get ids' that are specific to the instance running on your machine.  Postman is useful here and if you open up the collection I've given you can use that to submit

Example payload for success

```json

{
  "name": "Bobs Super Planting Plan",
  "layout_id": 10,
  "description": "arrgh man, yiv never seen mahters lyke it (say it in geordie)",
  "plans": [
    {
      "bed_id": 1,
      "plant_id": "tomato",
      "area": 1.8
    },
    {
      "bed_id": 2,
      "plant_id": "radish",
      "area": 3
    }
  ]
}
```

which returns the strategy and the plans. The plans belong to beds and that's how layouts > beds & strategies and plans play together.

```json
{
    "id": 8,
    "name": "Bobs Super Planting Plan",
    "description": "arrgh man, yiv never seen mahters lyke it",
    "plans": [
        { "id": 13, "area": 1.8,
            "bed": { "id": 1, "x": 0.0, "y": 0.0, "w": 2.5, "l": 1.8, "area": 4.5, "soil_id": 1 },
            "plant": { "name": "tomato", "id": 1 }
        },
        {
            "id": 14,
            "area": 3.0,
            "bed": { "id": 2, "x": 5.0, "y": 3.0, "w": 3.0, "l": 3.0, "area": 9.0, "soil_id": 2 },
            "plant": { "name": "radish", "id": 9 }
        }
    ],
    "score": null
}
```

And to demonstrate failure, here is a plan that massively exceeds the size of the bed

```json
{
  "name": "Excessively Optimistic",
  "layout_id": 10,
  "description": "Big bed. Not sure that is going to work",
  "plans": [
    { "bed_id": 1, "plant_id": "tomato", "area": 50 },
    { "bed_id": 2, "plant_id": "radish", "area": 3 }
  ]
}
```

which results in this error

```json
{
    "errors": {
        "area": [
            "The area of the plan exceeds the bed area of 4.5"
        ]
    }
}
```

Note: that error is less than good because it is not clear what bed is at fault. Add it to the todos... Normally I'd jump in and fix it, but I've drawn a line. It is these small things that break production applications (_the five minute jobs_)


### 3. Scores

I didn't complete this task.


## Endpoints

Here's the endpoints and I'd encourage you to open up postman or whatever tooling you use to interact with APIs and play around. I didn't get to complete the score endpoint for this challange but I'm likley to do that on my own time so that the work is completed. There's some nice learning about functional programming, async tasks and potential OTP scope in the fifth example. I digress (_I did say this was a conversational readme. Not how I'd normally do it, but communication is a part of the interview process_)

### Core Endpoints

These endpoints are the central endpoints for the application:

* `POST /v1/layouts` : creates a new layout with supplied beds. Atomic, anything fails - everything is rolledback. 
* `POST /v1/strategies` : creates a planting strategy and it's plans. Atomic, anything fails - everything is rolledback.
* 🚧 ~~`GET /v1/strategies/:id/scores` : shows the score for a given strategy and it's plans~~ 🚧 ask me this: why `GET`?

### Supplementary Endpoints

Other endpoints I added to make the second task of creating strategies and plans less painful and more joyful:

* `GET /v1/strategies/:id` : shows a strategy and it's relations 
* `GET /v1/layouts` : lists all layouts so layout_id and bed_ids are easy to get
* `GET /v1/layouts/:id` : shows a given layout and it's relations
* `GET /v1/soils` : shows all soils and their ids
* `GET /v1/plants` : shows all plants and their relations


-----------------------------------

## MISC NOTES

### Generators & Excess Code

I've used schema and migration generators, but I've stayed away from context generators. They tend to create a lot of code and whilst they save time on a project with a capital P, I find they create bloat on an exercise like this. Whilst I paid a little time penalty for this in creating some obvious context bondaries (list, get etc) I thought it was worth it so you can see more clearly how I approach something.

### AI

I declare that none of the code in the repository was written by AI. 



[0]: https://github.com/treejamie/hackerrank-90days
[1]: https://github.com/treejamie/helloworld/tree/main/elixir
[2]: https://github.com/treejamie/garden/releases/tag/time-limit
[3]: https://github.com/user-attachments/files/20361812/Verna.final.postman_collection.json


[4]: https://github.com/treejamie/garden/pulls?q=is%3Apr+is%3Aclosed
[5]: https://github.com/treejamie/garden/pull/7
[6]: https://github.com/treejamie/garden
