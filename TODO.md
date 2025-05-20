## Authorisation

Seems obvious but here is an API with write access. If this was online, someone/thing/group would find a way to use it in unintended and likley not legally abiding ways.


## Performance

There's a few places that have some smelly database work, tidying them up and wirting in some application performance monitoring would be a winner. That give insight into what needed to be addressed to increase performance.

## OTP

I didn't implement anything custom in OTP for this. It didn't see any place where it would be justified.
I just wanted to mention that because OTP is one of the crown jewels.


## Authentication / User Scopes

Ideally all layouts and beds should belong to a user.

Requests could be authentication using various means Bearer Tokens, oauth, SAML, and so on and so forth. But having things locked down so that users had to authenticate to become authorised to use the application seems like an obvious choice.

## Proper GeoSpatial with PostGIS

Probably a next step, I did start off with a PostGIS version, but I painted myself into a rollback corner and started again. If you're looking through the commit history and notice this is gone, then I succeeded in sneaking it in at the end. I've deliberately left specific places for implementing it where I think it'd be nice and clean. If I didn't succeed in my stretch and this text remains, then my question to you is what places do you think I've left as a clear boundary for this?

## Layout / Bed IDs

These are exposed publically and are increment based which leaves a requirement to defend against enumeration attacks.

# L18N

I've got some messages, especially error messages in which I've interpolated values to give meaningful feedback. However, It'd be better to use the Ecto method (transversing) of providing values for placeholders.

It'd also be a good time to internationalise everything and get all strings out of the application and under the control of gettext


## Indexes

Plant name and soil names would be something I'd index when the time came.


## CLI
Something to parse the api responses and present something a bit more useful on the command line. Example: `mix help phx.gen` nice tabular view kind of thing.


## on_delete: / on_replace:

My preference in the absence of other discussions is to do nothing until you know why you're doing something or what you're doing it for. 

> If don't need it and you have it == low cost
>
> If you don't have it and you need it == high cost.
> 
> However, if the price of data integrity / tidiness is higher than the high cost, change it to something that matches the strategy - :delete_all

This is an area of Ecto modelling that I have some learning to do.

## Models


### Plants

Some where created through the data ingestion. If this application was to be opened up to the public I'd allow planting plan endpoint to create plants that didn't already exist. As it is stands any plants not in the database, cause changset errors.  I'd probably adapt the scheme to make it clear where the plant came from -via some user id, or more broad flags such as source: [:user, :system]. Of course, then you start ending up with duplicates. Interesting problem.

### Gardens

#### Geometry & Map Projection
Placing a known origin of zero in latitude and longitude (WGS84) onto Layouts so that maps of the plan could be projected onto a map would be nice. You'd probably not even need PostGIS for this and you could do a lot with a frontend library.

### Plants - incompatible_with

Opposite of `benefits_from` but gives a place to provide a place for avoiding obvious mistakes in planting plans (e.g. english walnut Juglea regia releases allelopathic compounds.)

### Soils

If access by name continues, and data size wopuld grow, I'd put an index on names. One to watch because indexes are not free of charge.

## GraphQL vs REST

Seeing how nested everything is, I do wonder if GraphQL would have been better. It would have certainly abstracted the CSV input into a mutation. It's beena while since I've used GraphQL though and REST seemed like the obvious choice for this challenge.


## CSV vs JSON on inputs

I was torn here. The challenge said it's ok to change or extend the data files, but the spec on the felt clear about CSV. In the end, I went with JSON because of time.

It was faster to change the files to JSON, than it was to write a custom plug, parse the CSV and transform it into a map, which then ultimately was going to sent back as JSON.

If I had more time, and CSV was important to the design, I'd setup a new pipeline in the routers especially for CSV.

A faster halfway house solution would be a command line tool that took CSV, parsed that into JSON and then sent that over to the API as JSON. But that is kinda smelly from a general population UX perspective. Totally fine for engineers though. ♥️ CLIs.

I changed the data to this
```json
{
  "name": "Bob's Garden",
  "beds": [
  {
    "soil_id": "chalk",
    "x": 0,
    "y": 0,
    "w": 2.5,
    "l": 1.8
  },
  {
    "soil_id": "loam",
    "x": 5,
    "y": 3,
    "w": 3.0,
    "l": 3.0
  }
]
}


[1]: https://hexdocs.pm/ecto/Ecto.Changeset.html#cast_assoc/3 