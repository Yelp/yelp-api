//
//  NSURLRequest+OAuth.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 7/2/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "NSURLRequest+OAuth.h"
#import "YPMutableURLRequest.h"

/**
 OAuth credential placeholders that must be filled by each user in regards to
 http://www.yelp.com/developers/getting_started/api_access
 */
#warning Fill in the API keys below with your developer v2 keys.
static NSString * const kConsumerKey       = @"";
static NSString * const kConsumerSecret    = @"";
static NSString * const kToken             = @"";
static NSString * const kTokenSecret       = @"";

@implementation NSURLRequest (OAuth)

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path {
  return [self requestWithHost:host path:path params:nil];
}

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path params:(NSDictionary *)params {
  NSURL *URL = [self _URLWithHost:host path:path queryParameters:params];

  if ([kConsumerKey length] == 0 || [kConsumerSecret length] == 0 || [kToken length] == 0 || [kTokenSecret length] == 0) {
    NSLog(@"WARNING: Please enter your api v2 credentials before attempting any API request. You can do so in NSURLRequest+OAuth.m");
  }

  YPConsumer *consumer = [[YPConsumer alloc] initWithKey:kConsumerKey secret:kConsumerSecret];
  YPToken *token = [[YPToken alloc] initWithKey:kToken secret:kTokenSecret];

  YPMutableURLRequest *request = [[YPMutableURLRequest alloc] initWithURL:URL token:token consumer:consumer realm:nil signatureProvider:nil];

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
