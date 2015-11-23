# Yelp API v2 Haskell Example

## What is this? Where am I?
Do you love discovering local businesses and programming in Haskell? Then this
is the place to be! Here you'll find a small Haskell example program that uses
the Yelp v2 API.

## How do I use this?
First, you'll need to clone this repo.

Then, find the `src/Credentials.hs` file and open that up. You'll have to get
your own Yelp API credentials
[from here](https://www.yelp.com/developers/manage_api_keys), and fill in the
"CONSUMER KEY", "CONSUMER SECRET", "ACCESS TOKEN", and "ACCESS TOKEN SECRET"
string with your own credentials.

To compile, you'll need to install and configure `stack`, the Haskell
development tool. Yeah, yeah, yeah you just want to use ghc to compile it
without installing extra stuff, but stack makes things so much easier. It's
worth it. For info on how to get stack, 
[look here](https://github.com/commercialhaskell/stack)

Then, in this directory (yelp-api/v2/haskell), run:
`stack build`

And after it all compiles, run:
`stack exec haskell-yelp`

You will then be asked what you're looking for, and it will give you a list of
businesses and ratings in San Francisco that match. Not in San Francisco?
Perfect! Now you have an excuse to dive into the code and make some changes.
