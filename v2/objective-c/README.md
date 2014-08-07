# Yelp API v2 Objective-C code sample

## Overview
This program demonstrates the capability of the Yelp API version 2.0
by using the Search API to query for businesses by a search term and location,
and the Business API to query additional information about the top result
from the search query.

## Steps to run

Open the project with Xcode and do the following steps:

- Add your developer keys at the top of the NSURLRequest+OAuth.m file. You can find those keys in the section "[Manage your Keys](http://www.yelp.com/developers/manage_api_keys)" on Yelp's developer site.

- You can change the default term and location this program will be using in the main method of this program, under the strings `defaultTerm` and `defaultLocation`.

- Alternatively, you can edit the command line arguments if needed using the shortcut "Cmd + <" and then run the program in Xcode. The default pattern of the command line arguments that you want to give is: `-term 'the term here' -location 'the location here'`.



## More details

Please refer to [API documentation](http://www.yelp.com/developers/documentation)
for more details on the requests you can make on our API.