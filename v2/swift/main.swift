//
//  main.swift
//  YelpAPISample
//

import Foundation

// Fill in your API keys here from
// https://www.yelp.com/developers/manage_api_keys
let client = YLPClient(consumerKey: "",
                       consumerSecret: "",
                       token: "",
                       tokenSecret: "")

// Create a dispatch group to wait for search results
let group = dispatch_group_create()
dispatch_group_enter(group)

// Search for 3 dinner restaurants
client.searchWithLocation("San Francisco, CA",
                          currentLatLong: nil,
                          term: "dinner",
                          limit: 3,
                          offset: 0,
                          sort: .BestMatched)
{ search, error in
  // When leaving this completion handler, notify that the search finished
  defer {
    dispatch_group_leave(group)
  }

  // Check if we received a result; if not, there was an error
  guard let search = search else {
    print("Search errored: \(error)")
    return
  }

  guard let topBusiness = search.businesses.first else {
    print("No businesses found")
    return
  }

  print("Top business: \(topBusiness.name), id: \(topBusiness.identifier)")
}

// Wait for the search to complete
dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
