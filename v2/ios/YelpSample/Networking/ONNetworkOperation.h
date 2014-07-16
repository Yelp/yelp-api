//
//  ONNetworkOperation.h
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ONDownloadItem;

enum {
    ONNetworkOperation_Status_Waiting = 10,
    ONNetworkOperation_Status_Ready = 20,
    ONNetworkOperation_Status_Executing = 40,
    ONNetworkOperation_Status_Cancelled = 50,
    ONNetworkOperation_Status_Finished = 60
};
typedef NSUInteger ONNetworkOperation_Status;

typedef void (^ONNetworkOperationCompletionHandler)(NSData *data, NSError *error);

@interface ONNetworkOperation : NSOperation

@property (retain, readwrite) NSThread *runLoopThread; // default is nil, implying main thread
@property (retain, readonly) NSThread *actualRunLoopThread; // main thread if runLoopThread is nil, runLoopThread otherwise
@property (readonly, assign) BOOL isActualRunLoopThread; // YES if the current thread is the actual run loop thread

@property (copy, nonatomic) ONNetworkOperationCompletionHandler completionHandler;
@property (retain, nonatomic) NSURLConnection *connection;
@property (readonly) NSString *httpMethod;


@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *category;
@property (assign, nonatomic) ONNetworkOperation_Status status;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSMutableData *receivedData;

- (void)changeStatus:(ONNetworkOperation_Status)status;
- (NSTimeInterval)operationDuration;

- (void)startNetworkOperation;
- (void)cancelNetworkOperation;
- (void)failNetworkOperation;
- (void)finishNetworkOperation;

@end
