//
//  YPSignatureProvider.h
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

@protocol YPSignatureProvider <NSObject>

- (NSString *)name;
- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret;

@end