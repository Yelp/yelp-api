//
//  NSURLRequest+OAuth.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 7/2/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "NSURLRequest+OAuth.h"
#import "OAMutableURLRequest.h"
#import "YPAPISample.h"
#import "YourKeysAndTokens.h"

/**
 OAuth credential placeholders that must be filled by each user in regards to
 http://www.yelp.com/developers/getting_started/api_access
 */

@implementation NSURLRequest (OAuth)

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path {
  return [self requestWithHost:host path:path params:nil];
}

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path params:(NSDictionary *)params {
  NSURL *URL = [self _URLWithHost:host path:path queryParameters:params];

  if ([kConsumerKey length] == 0 || [kConsumerSecret length] == 0 || [kToken length] == 0 || [kTokenSecret length] == 0) {
    NSLog(@"WARNING: Please enter your api v2 credentials before attempting any API request. You can do so in NSURLRequest+OAuth.m");
  }

  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey secret:kConsumerSecret];
  OAToken *token = [[OAToken alloc] initWithKey:kToken secret:kTokenSecret];

  //The signature provider is HMAC-SHA1 by default and the nonce and timestamp are generated in the method
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL consumer:consumer token:token realm:nil signatureProvider:nil];
  [request setHTTPMethod:@"GET"];
  [request prepare]; // Attaches our consumer and token credentials to the request

  return request;
}

#pragma mark - URL Builder Helper

/**
 Builds an NSURL given a host, path and a number of queryParameters

 @param host The domain host of the API
 @param path The path of the API after the domain
 @param params The query parameters
 @return An NSURL built with the specified parameters
*/
+ (NSURL *)_URLWithHost:(NSString *)host path:(NSString *)path queryParameters:(NSDictionary *)queryParameters {

  NSMutableArray *queryParts = [[NSMutableArray alloc] init];
  for (NSString *key in [queryParameters allKeys]) {
    NSString *queryPart = [NSString stringWithFormat:@"%@=%@", key, queryParameters[key]];
    [queryParts addObject:queryPart];
  }

  NSURLComponents *components = [[NSURLComponents alloc] init];
  components.scheme = @"http";
  components.host = host;
  components.path = path;
  components.query = [queryParts componentsJoinedByString:@"&"];

  return [components URL];
}

@end
