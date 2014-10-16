//
//  YPToken.h
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPToken : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *secret;

- (instancetype)initWithKey:(NSString *)key secret:(NSString *)secret;
- (NSDictionary *)OAuthHeaderParameters;

@end
