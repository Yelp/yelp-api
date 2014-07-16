//
//  ONHeadRequestOpertion.h
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/19/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONNetworkOperation.h"

typedef void (^ONHeadRequestOperationCompletionHandler)(NSDictionary *dictionary, NSError *error);

@interface ONHeadRequestOpertion : ONNetworkOperation

@property (copy, nonatomic) ONHeadRequestOperationCompletionHandler headRequestCompletionHandler;

+ (void)addHeadRquestOperationWithURL:(NSURL *)url withHeadRequestCompletionHandler:(ONHeadRequestOperationCompletionHandler)headRequestCompletionHandler;

@end
