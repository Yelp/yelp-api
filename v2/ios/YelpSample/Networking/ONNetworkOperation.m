//
//  ONNetworkOperation.m
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONNetworkOperation.h"

#import "ONNetworkManager.h"

#define kDefaultHttpMethod              @"GET"

@interface ONNetworkOperation () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSDate *operationStartDate;
@property (strong, nonatomic) NSDate *operationEndDate;

- (BOOL)isCompleted;

- (NSString *)statusAsString;

@end

@implementation ONNetworkOperation

@synthesize runLoopThread = _runLoopThread;
@synthesize actualRunLoopThread= _actualRunLoopThread;
@synthesize isActualRunLoopThread = _isActualRunLoopThread;

@synthesize completionHandler = _completionHandler;

@synthesize connection = _connection;
@synthesize httpMethod = _httpMethod;
@synthesize operationStartDate = _operationStartDate;
@synthesize operationEndDate = _operationEndDate;

@synthesize url =_url;
@synthesize category = _category;
@synthesize status = _status;
@synthesize error = _error;

@synthesize response = _response;
@synthesize receivedData = _receivedData;

#pragma mark - Initialization
#pragma mark -

- (id)init {
    self = [super init];
    if (self != nil) {
        self.category = @"Default";
        self.status = ONNetworkOperation_Status_Waiting;
    }
    
    return self;
}

#pragma mark - Public Methods
#pragma mark -

- (void)changeStatus:(ONNetworkOperation_Status)status {
    if (self.status != ONNetworkOperation_Status_Ready && status == ONNetworkOperation_Status_Ready) {
        [self willChangeValueForKey:@"isReady"];
        self.status = ONNetworkOperation_Status_Ready;
        [self didChangeValueForKey:@"isReady"];
    }
    else if (self.status != ONNetworkOperation_Status_Executing && status == ONNetworkOperation_Status_Executing) {
        [self willChangeValueForKey:@"isExecuting"];
        self.status = ONNetworkOperation_Status_Executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    else if (self.status != ONNetworkOperation_Status_Cancelled && status == ONNetworkOperation_Status_Cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        self.status = ONNetworkOperation_Status_Cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    else if (self.status != ONNetworkOperation_Status_Finished && status == ONNetworkOperation_Status_Finished) {
        [self willChangeValueForKey:@"isFinished"];
        self.status = ONNetworkOperation_Status_Finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    else {
        self.status = status;
    }
}

- (NSTimeInterval)operationDuration {
    if (self.error != nil || self.operationStartDate == nil || self.operationEndDate == nil) {
        return 0.0;
    }
    
    CGFloat duration = [self.operationEndDate timeIntervalSinceDate:self.operationStartDate];
    return duration;
}

// Returns the effective run loop thread, that is, the one set by the user 
// or, if that's not set, the main thread.
- (NSThread *)actualRunLoopThread {
    NSThread *  result;
    
    result = self.runLoopThread;
    if (result == nil) {
        result = [NSThread mainThread];
    }
    return result;
}

// Returns YES if the current thread is the actual run loop thread.
- (BOOL)isActualRunLoopThread {
    return [[NSThread currentThread] isEqual:self.actualRunLoopThread];
}

- (NSString *)httpMethod {
    return kDefaultHttpMethod;
}

#pragma mark - Private Methods
#pragma mark -

- (NSString *)statusAsString {
    if (self.status == ONNetworkOperation_Status_Waiting) {
        return @"Waiting";
    }
    else if (self.status == ONNetworkOperation_Status_Ready) {
        return @"Ready";
    }
    else if (self.status == ONNetworkOperation_Status_Executing) {
        return @"Executing";
    }
    else if (self.status == ONNetworkOperation_Status_Cancelled) {
        return @"Cancelled";
    }
    else if (self.status == ONNetworkOperation_Status_Finished) {
        return @"Finished";
    }
    else {
        return @"Unknown";
    }
}

#pragma mark - NSObject Overrides
#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@, %@)", self.url.absoluteString, self.category, [self statusAsString]];
}

#pragma mark - Base Class Overrides
#pragma mark -

- (void)startNetworkOperation {
    // meant to be overridden
    
    assert(self.isActualRunLoopThread);
    
    // NOTE: Networking on the networking queue should not be happening on the main queue
    assert(dispatch_get_main_queue() != dispatch_get_current_queue());
        
    // use the default cache policy to do the memory/disk caching
    NSMutableURLRequest *request = [NSMutableURLRequest 
                                    requestWithURL:self.url 
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                    timeoutInterval:30];
    
    if (! [[self httpMethod] isEqualToString:kDefaultHttpMethod]) {
        [request setHTTPMethod:[self httpMethod]];
    }
    
    // ensure a fresh response is returned
    [request setValue:@"Cache-Control" forHTTPHeaderField:@"no-cache"];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection start];
    
    if (self.connection == nil) {
        /* inform the user that the connection failed */
        
        NSString *errorMessage = [NSString stringWithFormat:@"Error creating connection (%@)", self.url];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"ONNetworkOperationErrorDomain"
                                             code:100
                                         userInfo:userInfo];
        self.error = error;
        [self failNetworkOperation];
        return;
    }
    
    [[ONNetworkManager sharedInstance] didStartNetworking];
}

- (void)cancelNetworkOperation {
    @synchronized (self) {
        self.operationEndDate = [NSDate date];
        [self.connection cancel];
        [[ONNetworkManager sharedInstance] didStopNetworking];
        [self changeStatus:ONNetworkOperation_Status_Cancelled];
    }
}

- (void)failNetworkOperation {
    @synchronized (self) {
        self.operationEndDate = [NSDate date];
        [[ONNetworkManager sharedInstance] didStopNetworking];
        [self changeStatus:ONNetworkOperation_Status_Finished];
        self.completionHandler(nil, self.error);
    }
}

- (void)finishNetworkOperation {
    @synchronized (self) {
        self.operationEndDate = [NSDate date];
        [[ONNetworkManager sharedInstance] didStopNetworking];
        [self changeStatus:ONNetworkOperation_Status_Finished];
        self.completionHandler(self.receivedData, nil);
    }
}

- (BOOL)isCompleted {
    return [self isCancelled] || [self isFinished];
}

#pragma mark - NSOperation Overrides
#pragma mark -

- (void)start {
    [super start];
    
    assert(![self isCompleted]);
    assert([self.actualRunLoopThread isExecuting]);
    assert(![self.actualRunLoopThread isCancelled]);

    self.operationStartDate = [NSDate date];
    [self changeStatus:ONNetworkOperation_Status_Executing];
    
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    [self performSelector:@selector(startNetworkOperation) onThread:self.actualRunLoopThread withObject:nil waitUntilDone:NO modes:modes];
}

- (void)cancel {    
    // any thread
    
    @synchronized (self) {
        // Call our super class so that isCancelled starts returning true immediately.
        [super cancel];
        [self cancelNetworkOperation];
        [self changeStatus:ONNetworkOperation_Status_Cancelled];
    }
}

- (BOOL)isReady {
    // any thread
    return self.status == ONNetworkOperation_Status_Ready;
}

- (BOOL)isConcurrent {
    // any thread
    return YES;
}

- (BOOL)isExecuting {
    // any thread
    return self.status == ONNetworkOperation_Status_Executing;
}

- (BOOL)isCancelled {
    // any thread
    return self.status == ONNetworkOperation_Status_Cancelled;
}

- (BOOL)isFinished {
    // any thread
    return self.status == ONNetworkOperation_Status_Finished;
}

#pragma mark - NSURLConnectionDataDelegate
#pragma mark -

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
	/* create the NSMutableData instance that will hold the received data */
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        self.response = (NSHTTPURLResponse *)response;
    }
    
    if([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            
            NSString *errorMessage = [NSString stringWithFormat:@"Error during network operation: %i", httpResponse.statusCode];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"ONNetworkOperationErrorDomain"
                                                 code:httpResponse.statusCode
                                             userInfo:userInfo];
            self.error = error;
            [self failNetworkOperation];
            return;
        }
    }
    
	long long contentLength = [response expectedContentLength];
	if (contentLength == NSURLResponseUnknownLength) {
		contentLength = 500000;
	}
	self.receivedData = [NSMutableData dataWithCapacity:(NSUInteger)contentLength];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    self.error = error;
    [self failNetworkOperation];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    [self finishNetworkOperation];
}

@end
