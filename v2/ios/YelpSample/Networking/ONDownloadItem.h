//
//  ONDownloadItem.h
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ONNetworkOperation.h"

enum {
    ONDownloadItem_Priority_Low = 100,
    ONDownloadItem_Priority_Medium = 200,
    ONDownloadItem_Priority_High = 300
};
typedef NSUInteger ONDownloadItem_Priority;

@interface ONDownloadItem : NSObject

- (id)initWithURL:(NSURL *)url;

- (id)initWithURL:(NSURL *)url andPriority:(ONDownloadItem_Priority)priority;

- (NSString *)cacheKey;

@property (strong, nonatomic) NSURL *url;
@property (readonly, nonatomic) NSString *cacheKey;
@property (assign, nonatomic) ONDownloadItem_Priority priority;
@property (assign, nonatomic) NSUInteger retryCount;
@property (assign, nonatomic) NSUInteger maxRetryCount;

+ (void)addDownloadOperationWithURL:(NSURL *)url andPriority:(ONDownloadItem_Priority)priority andCategory:(NSString *)category withCompletionHandler:(ONNetworkOperationCompletionHandler)completionHandler;

@end
