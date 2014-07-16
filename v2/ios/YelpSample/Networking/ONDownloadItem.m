//
//  ONDownloadItem.m
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONDownloadItem.h"

#import "ONNetworkManager.h"
#import "ONDownloadOperation.h"
#import "ONNetworkOperation.h"

#define kEmptyCacheKey  @"";

@implementation ONDownloadItem

@synthesize url = _url;
@synthesize cacheKey = _cacheKey;
@synthesize priority = _priority;
@synthesize retryCount = _retryCount;
@synthesize maxRetryCount = _maxRetryCount;

- (id)initWithURL:(NSURL *)url {
    return [self initWithURL:url andPriority:ONDownloadItem_Priority_Medium];
}

- (id)initWithURL:(NSURL *)url andPriority:(ONDownloadItem_Priority)priority {
    self = [super init];
    if (self != nil) {
        self.url = url;
        self.priority = priority;
    }
    return self;
}

- (NSString *)cacheKey {
    if (self.url == nil) {
        return kEmptyCacheKey;
    }
    NSMutableString *str = [NSMutableString stringWithString:self.url.absoluteString];
    
    [str replaceOccurrencesOfString:@"://" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"/" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    
    return str;
}

+ (void)addDownloadOperationWithURL:(NSURL *)url andPriority:(ONDownloadItem_Priority)priority andCategory:(NSString *)category withCompletionHandler:(ONNetworkOperationCompletionHandler)completionHandler {
    ONDownloadItem *downloadItem = [[ONDownloadItem alloc] initWithURL:url];
    ONDownloadOperation *downloadOperation = [[ONDownloadOperation alloc] initWithDownloadItem:downloadItem];
    downloadOperation.completionHandler = completionHandler;
    [[ONNetworkManager sharedInstance] addOperation:downloadOperation];
}

@end
