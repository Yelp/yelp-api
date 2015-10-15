# Yelp API v2 Objective-C code sample

## Overview

This program demonstrates the capability of the Yelp API version 2.0 in two ways:

- It uses the Search API to query for businesses by a search term and location.
- It uses the Business API to query additional information about the top result from the search query.

## Steps to run

Open the project with Xcode and do the following steps:

- Add your developer keys at the top of NSURLRequest+OAuth.m. These keys can be found in the section "[Manage your Keys](http://www.yelp.com/developers/manage_api_keys)" on Yelp's developer site.

- Optionally, change the default term and location used in the sample search by editing the following variables in the `main` function in main.m: `defaultTerm` and `defaultLocation`. These variables can also be overridden via command line options.

## Command Line Options

- `-term <term>`
- `-location <location>`

For help with Xcode program arguments, see "[Running Your Application with Arguments](https://developer.apple.com/library/mac/recipes/xcode_help-scheme_editor/Articles/SchemeRun.html)"

## More details

Please refer to [API documentation](http://www.yelp.com/developers/documentation)
for more details on the requests you can make on our API.
