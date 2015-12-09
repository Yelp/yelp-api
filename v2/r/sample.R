# Yelp API v2.0 code sample.
# 
# This program demonstrates the capability of the Yelp API version 2.0
# by using the Search API to query for businesses by a search term and location.
# 
# Please refer to http://www.yelp.com/developers/documentation for the API documentation.
# 
# This program requires some R libraries including "httr", which you can install via:
# `packages.install("httr")`
# `packages.install("httpuv")`
# etc.
# 
# Sample usage of the program:
# `> source("sample.R")`
# (output to the screen)
# or
# `R CMD BATCH sample.R`
# (output to sample.Rout)

# Required packages
require(httr)
require(httpuv)
require(jsonlite)
require(base64enc)

# Your credentials, from https://www.yelp.com/developers/manage_api_keys
consumerKey = ""
consumerSecret = ""
token = ""
token_secret = ""

# Use OAuth to authorize your request.
myapp = oauth_app("YELP", key=consumerKey, secret=consumerSecret)
sig = sign_oauth1.0(myapp, token=token,token_secret=token_secret)

# Dinner in Boston
# TODO (kmitton): quote query string.
yelpurl <- paste0("http://api.yelp.com/v2/search/?term=dinner&location=Boston%20MA&limit=3")
print(yelpurl)

# Make request.
locationdata=GET(yelpurl, sig)

# If status not success, print some debugging output.
HTTP_SUCCESS <- 200
if (locationdata$status != HTTP_SUCCESS) {
    print(locationdata)
}

# Load data.  Flip it around to get an easy-to-handle list.
locationdataContent = content(locationdata)
locationdataList=jsonlite::fromJSON(toJSON(locationdataContent))

# Print output.
print(head(data.frame(locationdataList)))
