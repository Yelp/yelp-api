//
//  YPToken.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "YPToken.h"

@implementation YPToken

- (instancetype)initWithKey:(NSString *)key secret:(NSString *)secret {
  if (self = [super init]) {
      self.key = key;
      self.secret = secret;
  }

  return self;
}

- (NSDictionary *)OAuthHeaderParameters {
  return @{ @"oauth_token" : self.key };
}

@end
