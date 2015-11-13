# Yelp API v2 Haskell Example

## What is this? Where am I?
Do you love discovering local businesses and programming in Haskell? Then this
is the place to be! Here you'll find a small Haskell example program that uses
the Yelp v2 API.

## How do I use this?
First, you'll need to install and configure `stack`, the Haskell development
tool. For info on how to do this, look
[here](https://github.com/commercialhaskell/stack)

Then, in this directory, run:
`stack build`

And after it all compiles, run:
`stack exec haskyelp`

You will then be asked what you're looking for, and it will give you a list of
businesses and ratings in San Francisco that match. Not in San Francisco?
Perfect! Now you have an excuse to dive into the code and make some changes.
