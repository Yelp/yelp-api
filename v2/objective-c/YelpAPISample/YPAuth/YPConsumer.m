//
//  YPConsumer.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "YPConsumer.h"

@implementation YPConsumer

- (instancetype)initWithKey:(NSString *)key secret:(NSString *)secret {
  if (self = [super init]) {
    self.key = key;
    self.secret = secret;
  }

  return self;
}

@end
