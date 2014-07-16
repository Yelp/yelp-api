//
//  ONDownloadOperation.m
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONDownloadOperation.h"

#import "ONNetworkManager.h"

#define kONDownloadOperation_CancelNotificationName        @"ONDownloadOperation_CancelNotificationName"
#define kONDownloadOperation_URLNoticationKey              @"ONDownloadOperation_URLNoticationKey"

@interface ONDownloadOperation ()

// observers are retained by the system
@property (nonatomic, assign) id cancelDownloadObserver;

@end

@implementation ONDownloadOperation

@synthesize cancelDownloadObserver = _cancelDownloadObserver;

@synthesize downloadItem = _downloadItem;

- (id)initWithDownloadItem:(ONDownloadItem *)downloadItem {
    return [self initWithDownloadItem:downloadItem andCategory:@"Default"];
}

- (id)initWithDownloadItem:(ONDownloadItem *)downloadItem andCategory:(NSString *)category {
    self = [super init];
    if (self != nil) {
        self.url = downloadItem.url;
        self.downloadItem = downloadItem;
        self.category = category;
        self.status = ONNetworkOperation_Status_Waiting;
        
        if (self.downloadItem.priority == ONDownloadItem_Priority_Low) {
            [self setQueuePriority:NSOperationQueuePriorityLow];
        }
        else if (self.downloadItem.priority == ONDownloadItem_Priority_Medium) {
            [self setQueuePriority:NSOperationQueuePriorityNormal];
        }
        else if (self.downloadItem.priority == ONDownloadItem_Priority_High) {
            [self setQueuePriority:NSOperationQueuePriorityHigh];
        }
    }
    return self;
}

@end
