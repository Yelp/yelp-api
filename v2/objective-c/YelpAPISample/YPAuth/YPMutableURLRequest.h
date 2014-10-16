//
//  YPMutableURLRequest.h
//  YelpAPISample
//
//  Created by Thibaud Robelain on 16/10/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YPToken.h"
#import "YPConsumer.h"
#import "YPHMAC_SHA1SignatureProvider.h"

@interface YPMutableURLRequest : NSMutableURLRequest

- (instancetype)initWithURL:(NSURL *)URL token:(YPToken *)token consumer:(YPConsumer *)consumer realm:(NSString *)realm signatureProvider:(id<YPSignatureProvider>)signatureProvider;

@end
