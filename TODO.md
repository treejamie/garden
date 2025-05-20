## Proper GeoSpatial with PostGIS

Probably a next step, I did start off with a PostGIS version, but I painted myself into a rollback corner and started again. If you're looking through the commit history and notice this is gone, then I succeeded in sneaking it in at the end. I've deliberately left specific places for implementing it where I think it'd be nice and clean. If I didn't succeed in my stretch and this text remains, then my question to you is what two places do you think I've left as a clear boundary for this?

## Layout / Bed IDs

These are exposed publically and are increment based which leaves a requirement to defend against enumeration attacks.


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

