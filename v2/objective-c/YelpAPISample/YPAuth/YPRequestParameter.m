//
//  YPRequestParameter.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "YPRequestParameter.h"
#import "NSString+URLEncoding.h"

@implementation YPRequestParameter

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value {
  if (self = [super init]) {
    self.key = key;
    self.value = value;
  }

  return self;
}

#pragma mark - Helpers

- (NSString *)URLEncodedKey {
  return [self.key encodedURLParameterString];
}

- (NSString *)URLEncodedValue {
  return [self.value encodedURLParameterString];
}

- (NSString *)URLEncodedKeyValuePair {
  return [NSString stringWithFormat:@"%@=%@", [self URLEncodedKey], [self URLEncodedValue]];
}

@end
