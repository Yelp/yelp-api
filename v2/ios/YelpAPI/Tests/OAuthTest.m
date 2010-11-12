//
//  OAuthTest.m
//  YelpAPI
//
//  Created by Gabriel Handford on 11/12/10.
//  Copyright 2010 Yelp. All rights reserved.
//

#import "OAuthConsumer.h"

@interface OAuthTest : GHAsyncTestCase { 
  NSMutableData *_responseData;
}
@end

@implementation OAuthTest

- (void)tearDown {
  [_responseData release];
  _responseData = nil;
}

- (void)test {
  
  // OAuthConsumer doesn't handle pluses in URL, only percent escapes
  // OK: http://api.yelp.com/v2/search?term=restaurants&location=new%20york
  // FAIL: http://api.yelp.com/v2/search?term=restaurants&location=new+york
  
  // OAuthConsumer has been patched to properly URL escape the consumer and token secrets 
  
  NSURL *URL = [NSURL URLWithString:@"http://api.yelp.com/v2/search?term=restaurants&location=new%20york"];
  OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"CONSUMER_KEY" secret:@"CONSUMER_SECRET"] autorelease];
  OAToken *token = [[[OAToken alloc] initWithKey:@"TOKEN" secret:@"TOKEN_SECRET"] autorelease];  
  
  id<OASignatureProviding, NSObject> provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
  NSString *realm = nil;  
    
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                 consumer:consumer
                                                                    token:token
                                                                    realm:realm
                                                        signatureProvider:provider];
  [request prepare];

  _responseData = [[NSMutableData alloc] init];
  [self prepare];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
  
  id JSON = [_responseData yajl_JSON];
  GHTestLog(@"JSON: %@", [JSON yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"  "]);
  
  [connection release];
  [request release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"Error: %@, %@", [error localizedDescription], [error localizedFailureReason]);
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(test)];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test)];
}

@end