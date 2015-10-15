# Yelp API v2 C# Code Sample

## Overview
This program demonstrates the capability of the Yelp API version 2.0
by using the Search API to query for businesses by a search term and location,
and the Business API to query additional information about the top result
from the search query.

Please refer to [API documentation](http://www.yelp.com/developers/documentation)
for more details.

Sample usage of the program:
`YelpAPI.exe --term="bars" --location="San Francisco, CA"`


## Steps to run

1. Install the NuGet Package Manager for Visual Studio 2010 and up
[here](http://visualstudiogallery.msdn.microsoft.com/27077b70-9dad-4c64-adcf-c7cf6bc9970c),
if you do not already have it installed.

2. Open `YelpAPI.sln` with Visual Studio.

3. Click "Build" > "Build Solution".

4. Go to the "Debug" directory in the project folder, and open `YelpAPI.exe`.