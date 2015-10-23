//
//  YPRequestParameter.h
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPRequestParameter : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *value;

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value;
- (NSString *)URLEncodedKeyValuePair;

@end
