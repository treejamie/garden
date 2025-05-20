# Garden

*General public*: 🤓 This is not a real application designed for real world use. It is an application I was asked to do as part of a technical interview for a position somewhere. The rest of this readme is written in a conversational style, and would not normally be how I'd write an README.md. An example of how I would normally approach a readme can be found [here][0] and [here][1].

*Interviewers*: 👋 Hello, I'm Jamie and look forward to discussing my work with you. Normally I'd run my readmes through an LLM to make them less wordy and less me, but in this case I've left them as is. Forgive any typos. It's written half conversationally and half as I would. It's not normally how I'd write a readme.

Generally speaking my approach has been to leave out any superflous functionality and to only do the minimum that I'd be happy with if I was deploy this, as my responsibility, with my own payment details. That being said, with the time constraint I didn't have time to write a conceptually minimal app. The domain is somewhat familiar to me and this app felt like a baby version of a woodland creation tool.

## Aims

This application has two aims. The first is to provide an insight into how I write code, the way that I approach the writing of code and my general ability to solve a problem. Obviously, this is important. You may find blocks of comments that contain statements of thought in them. In production code I'd not leave such things in place so easily, but I saw some value in leaving them there as conversational talking points.

The second aim is to build an application that allows people to create garden layouts with beds. These beds have some data about them _(geometry, soil types_) and are saved against the layout. Once saved people can create plans for each bed and the application will give scores for each plan based on various factors.


## Experience

The command line is how the user will interface with the API (_or maybe postman if that's how you roll_).

There should be three distinct stages from starting to getting a plan.

1. Create the layout with the beds and data about the beds. 
2. Create the plans for each bed. 
3. Query for a score for their plan.

I've aimed to hit the spec, but I'm leaning towards adding a few helper API endpoints to make the whole experience nicer and easier to use. Extra API endpoints:

* `GET /v1/layouts` - returns all layouts
* `GET /v1/layouts/:id/beds` - returns all beds for a given layout
* `GET /v1/soils` - returns all soil types available in the application
* `GET /v1/plants` - returns all plants available in the application

These endpoints are the central endpoints for the application:

* `POST /v1/layouts` - creates a new layout with supplied beds

These endpoints all the application to be used entirely from the command line and would make the putting together of CSV nicer. How would someone know the bed id of something if I didn't provide these?




## Installation

### Requirements

This application was built using the below versions. It would likley work on other versions and if this was anything other than a demo, I'd give a list of full compatibility and ensure they were added into the CI tests.

* Phoenix - 1.7.21
* Elixir - 1.18.3
* Erlang - 27.3.4
* Postgres - 17.5


## Generators & Code

I've used schema and migration generators, but I've stayed away from context generators. They tend to create a lot of code and whilst they save time on a project with a capital P, I find they create bloat on an exercise like this. Whilst I paid a little time penalty for this in creating some obvious Context bondaries (list, get etc) I thought it was worth it so you can see more clearly how I approach something.



[0]: https://github.com/treejamie/hackerrank-90days
[1]: https://github.com/treejamie/helloworld/tree/main/elixir
