//
//  ONHeadRequestOpertion.m
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/19/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONHeadRequestOpertion.h"

#import "ONNetworkManager.h"
#import "NSDate+InternetDateTime.h"

@implementation ONHeadRequestOpertion

@synthesize headRequestCompletionHandler = _headRequestCompletionHandler;

- (NSString *)httpMethod {
    return @"HEAD";
}

- (void)finishNetworkOperation {
    [super finishNetworkOperation];
    
    @synchronized (self) {
        // assemble dictionary and call headRequestCompletionHandler
        
        if (self.error != nil) {
            self.headRequestCompletionHandler(nil, self.error);
        }
        else {
            // a non-HTTP response will fail the following assertion
            assert(self.response != nil);
            
            // parse header values from response and build dictionary to return
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSHTTPURLResponse *response = self.response;
            
            //> curl --head http://www.acme.com/data.xml
            //HTTP/1.1 200 OK
            //Date: Thu, 19 Jul 2012 19:09:44 GMT
            //Server: Apache
            //Last-Modified: Wed, 11 Jul 2012 15:03:49 GMT
            //ETag: "182eb49-cec8-4c48f27815f40"
            //Accept-Ranges: bytes
            //Content-Length: 52936
            //Connection: close
            //Content-Type: application/xml
            
            [dict setValue:[NSNumber numberWithInt:response.statusCode] forKey:@"statusCode"];
            NSString *contentType = [[response allHeaderFields] objectForKey:@"Content-Type"];
            if (contentType != nil) {
                [dict setValue:contentType forKey:@"contentType"];
            }
            
            NSString *lastModifiedString = [[response allHeaderFields] objectForKey:@"Last-Modified"];
            NSDate *lastModified = [NSDate dateFromInternetDateTimeString:lastModifiedString formatHint:DateFormatHintRFC822];
            if (lastModified != nil) {
                [dict setValue:lastModified forKey:@"lastModified"];
            }
            
            NSString *eTag = [[response allHeaderFields] objectForKey:@"ETag"];
            if (eTag != nil) {
                [dict setValue:eTag forKey:@"eTag"];
            }
            
            NSUInteger contentLength = [[[response allHeaderFields] objectForKey:@"Content-Length"] intValue];
            [dict setValue:[NSNumber numberWithInt:contentLength] forKey:@"contentLength"];
            
            self.headRequestCompletionHandler(dict, nil);
        }
    }
}

+ (void)addHeadRquestOperationWithURL:(NSURL *)url withHeadRequestCompletionHandler:(ONHeadRequestOperationCompletionHandler)headRequestCompletionHandler {
    
    ONHeadRequestOpertion *operation = [[ONHeadRequestOpertion alloc] init];
    operation.url = url;
    operation.headRequestCompletionHandler = headRequestCompletionHandler;
    operation.completionHandler = ^(NSData *data, NSError *error) {}; // do nothing
    
    [[ONNetworkManager sharedInstance] addOperation:operation];
}

@end
