*Interviewers*: 👋 Hello, I'm Jamie and look forward to discussing my work with you. Normally I'd run my readmes through an LLM to make them less wordy and less me, but in this case I've left them as is. Forgive any typos. It's semi-coversationally and is not how I would normally write a readme. An example of how I would normally approach a readme can be found [here][0] and [here][1]. Ok, that being said, on with the show...

There was a 3-4 hour time limit but in total I likley spent about 8-10 hours on it over the course of 20-21st May 2025. I did [tag the state of the application at the time limit][2]. What you see here is the final output for my submission which will also be tagged, but I cannot link that until I've written this. Circular dependancy 😆.

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


```
elixir 1.18.3-otp-27
erlang 27.3.4
```

## Installation

1. `git clone git@github.com:treejamie/garden.git`
2. `cd garden`
3.  **asdf users only**: `asdf install`
4. `mix deps.get && mix.compile`
5. `mix setup` (_creates databases and imports background-knowledge_)
6. `mix phx.server` or `iex -S mix phx.server` (_project has a .iex.exs file to make iex sessions joyful with a preconfigured environment_) 

If you're using postman, you can also optionally use the [supplied postman collection][3]. 

## Creating Plans

### 1. Layouts and Beds

Before there can be a strategy with plans for each bed, there has to be a layout with beds. Let's build that first and as this is the first thing you're creating, you can use the following command line tool.  


## Aims

This application has two aims. The first is to provide an insight into how I write code, the way that I approach the writing of code and my general ability to solve a problem. Obviously, this is important. You may find blocks of comments that contain statements of thought in them. In production code I'd not leave such things in place so easily, but I saw some value in leaving them there as conversational talking points.

The second aim is to build an application that allows people to create garden layouts with beds. These beds have some data about them _(geometry, soil types_) and are saved against the layout. Once saved people can create plans for each bed and the application will give scores for each plan based on various factors.






I've aimed to hit the spec, but I'm leaning towards adding a few helper API endpoints to make the whole experience nicer and easier to use. Extra API endpoints:

* `GET /v1/layouts` - returns all layouts
* `GET /v1/layouts/:id` - returns the layout and shows all beds for a given layout
* `GET /v1/soils` - returns all soil types available in the application
* `GET /v1/plants` - returns all plants available in the application

These endpoints are the central endpoints for the application:

* `POST /v1/layouts` - creates a new layout with supplied beds

These endpoints all the application to be used entirely from the command line and would make the putting together of CSV nicer. How would someone know the bed id of something if I didn't provide these?



## Generators & Code

I've used schema and migration generators, but I've stayed away from context generators. They tend to create a lot of code and whilst they save time on a project with a capital P, I find they create bloat on an exercise like this. Whilst I paid a little time penalty for this in creating some obvious Context bondaries (list, get etc) I thought it was worth it so you can see more clearly how I approach something.



[0]: https://github.com/treejamie/hackerrank-90days
[1]: https://github.com/treejamie/helloworld/tree/main/elixir
[2]: https://github.com/treejamie/garden/releases/tag/time-limit
[3]: https://github.com/user-attachments/files/20361812/Verna.final.postman_collection.json