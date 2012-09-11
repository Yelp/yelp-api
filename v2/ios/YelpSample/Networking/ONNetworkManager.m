//
//  ONNetworkManager.m
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONNetworkManager.h"

#import "ONDownloadItem.h"
#import "ONDownloadOperation.h"

// NOTES
// A download queue will regulate downloads. DownloadOperations will be added to the queue
// and counted as they are in progress and new items will be added based on priority.
// A list of downloads will be downloaded at times and should be downloaded in the background
// with the ability for priority items to skip ahead of the line. Images will be handled 
// differently than XML and other downloads because they take longer to download and will be
// stored using EGOCache.

// Look into ASIHTTPRequest - http://allseeing-i.com/ASIHTTPRequest/

#pragma mark - Constants
#pragma mark -

#define kDefaultMaxConcurrentOperationCount    8

#pragma mark - Class Extension
#pragma mark -

@interface ONNetworkManager ()

@property (strong, nonatomic) NSThread *networkRunLoopThread;
@property (strong, nonatomic) NSOperationQueue *networkQueue;
@property (strong, nonatomic) NSMutableArray *operations;
@property (assign, nonatomic) NSUInteger queuedCount;

@end

#pragma mark -

@implementation ONNetworkManager {
    NSUInteger networkingCount;
}

#pragma mark - Properties
#pragma mark -

@synthesize networkRunLoopThread = _networkRunLoopThread;
@synthesize networkQueue = _networkQueue;
@synthesize operations = _operations;
@synthesize queuedCount = _queuedCount;

#pragma mark - Singleton
#pragma mark -

SYNTHESIZE_SINGLETON_FOR_CLASS(ONNetworkManager);

#pragma mark - Initialization
#pragma mark -

- (id)init {
    self = [super init];
    if (self != nil) {
        self.networkQueue = [[NSOperationQueue alloc] init];
        self.networkQueue.maxConcurrentOperationCount = kDefaultMaxConcurrentOperationCount;
        self.operations = [NSMutableArray array];
        self.queuedCount = 0;
        
        // We run all of our network callbacks on a secondary thread to ensure that they don't 
        // contribute to main thread latency.  Create and configure that thread.
        
        self.networkRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRunLoopThreadEntry) object:nil];
        assert(self.networkRunLoopThread != nil);
        
        [self.networkRunLoopThread setName:@"networkRunLoopThread"];
        if ( [self.networkRunLoopThread respondsToSelector:@selector(setThreadPriority)] ) {
            [self.networkRunLoopThread setThreadPriority:0.3];
        }
        
        [self.networkRunLoopThread start];
    }
    return self;
}

// This thread runs all of our network operation run loop callbacks.
- (void)networkRunLoopThreadEntry {
    assert( ! [NSThread isMainThread] );
    while (YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    }
    assert(NO);
}

#pragma mark - Implementation
#pragma mark -

- (void)setMaxConcurrentOperationCount:(NSUInteger)maxCount {
    self.networkQueue.maxConcurrentOperationCount = maxCount;
}

- (void)addOperations:(NSArray *)operations {
    @synchronized(self) {
        NSArray *sorted = [ONNetworkManager sortOperations:operations];
        for (ONNetworkOperation *operation in sorted) {
            [self addOperation:operation];
        }
    }
}

- (void)addOperation:(ONNetworkOperation *)operation {
    @synchronized(self) {
        
        // ensure the NSRunLoop thread is running
        assert([self.networkRunLoopThread isExecuting]);
        assert(![self.networkRunLoopThread isFinished]);
        assert(![self.networkRunLoopThread isCancelled]);
        
        [self.operations addObject:operation];
        
        __weak ONNetworkOperation *weakOperation = operation;
        
        [operation setCompletionBlock:^{
            @synchronized(self) {
                self.queuedCount--;
                [self.operations removeObject:weakOperation];
            }
        }];
        
        assert([operation respondsToSelector:@selector(setRunLoopThread:)]);
        
        if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
            if ( [(id)operation runLoopThread] == nil ) {
                [ (id)operation setRunLoopThread:self.networkRunLoopThread];
            }
        }
        
        [self.networkQueue addOperation:operation];
        [operation changeStatus:ONNetworkOperation_Status_Ready];
        self.queuedCount++;
    }
}

- (void)cancelOperation:(ONNetworkOperation *)operation {
    @synchronized(self) {
        [operation cancel];
        [self.operations removeObjectIdenticalTo:operation];
    }
}

- (void)cancelOperationsWithCategory:(NSString *)category {
    @synchronized(self) {
        NSMutableArray *operationsToCancel = [NSMutableArray array];
        for (ONNetworkOperation *operation in self.operations) {
            if ([operation.category isEqualToString:category]) {
                [operationsToCancel addObject:operation];
            }
        }
        
        for (ONNetworkOperation *operation in operationsToCancel) {
            [self cancelOperation:operation];
        }
    }
}

- (void)cancelAll {
    @synchronized(self) {
        [self.networkQueue cancelAllOperations];
        [self.operations removeAllObjects];
    }
}

- (void)logOperations {
    @synchronized(self) {
        DebugLog(@"There are %i active operations", [self operationsCount]);
        for (ONNetworkOperation *operation in self.operations) {
            DebugLog(@"%@", operation);
        }
    }
}

+ (NSArray *)sortOperations:(NSArray *)operations {
    // sort by status (waiting, queued, finished), priority, category
    NSArray *sorted = [operations sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[ONNetworkOperation class]] && [obj1 isKindOfClass:[ONNetworkOperation class]]) {
            ONNetworkOperation *op1 = (ONNetworkOperation *)obj1;
            ONNetworkOperation *op2 = (ONNetworkOperation *)obj2;
            
            NSComparisonResult result = (NSComparisonResult)NSOrderedSame;
            
            result = [[NSNumber numberWithInt:op1.status] compare:[NSNumber numberWithInt:op2.status]];
            
            if (result != NSOrderedSame) {
                if ([obj1 isKindOfClass:[ONDownloadOperation class]] && 
                    [obj1 isKindOfClass:[ONDownloadOperation class]]) {
                    ONDownloadOperation *dop1 = (ONDownloadOperation *)op1;
                    ONDownloadOperation *dop2 = (ONDownloadOperation *)op2;
                    
                    result = [[NSNumber numberWithInt:dop2.downloadItem.priority] 
                              compare:[NSNumber numberWithInt:dop1.downloadItem.priority]];
                }
            }
            
            if (result != NSOrderedSame) {
                result = [op1.category compare:op2.category];
            }
            
            return result;
        }
        
        // fall through in case object types do not match
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sorted;
}

- (void)didStartNetworking {
    networkingCount += 1;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didStopNetworking {
    if (networkingCount > 0) {
        networkingCount -= 1;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: (networkingCount > 0)];
}

- (NSUInteger)operationsCount {
    return self.queuedCount;
}

@end
