//
//  CTYelpService.m
//  CodeTest
//
//  Created by Brennan Stehling on 9/3/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "YPYelpService.h"

// Yelp API 1.0

#define kYelpWSID               @"pc5Oq2YkcnyWIyF0gzSZUw"

// Yelp API 2.0

#define kYelpConsumerKey        @"7Dho3n2dDsiLcrqSuPo-ZA"
#define kYelpConsumerSecret     @"9hZdLlyLJ0yiwDCnD0jTu9uvzww"
#define kYelpToken              @"FK27DFAIaA3mpUcRAhXEaB_3JUMwVu4G"
#define kYelpTokenSecret        @"ELvhkBOVkWCDQ8Gwhl_jyDoD6js"

#import "OAuthConsumer.h"
#import "NSString+URLEncoding.h"

//    Usage:
//
//    YPYelpService *yelpService = [[YPYelpService alloc] init];
//    [yelpService searchWithQuery:@"pizza" location:@"San Francisco" withCompletionBlock:^{
//        if (yelpService.error) {
//            DebugLog(@"Error: %@: %@", [yelpService.error localizedFailureReason], [yelpService.error localizedDescription]);
//        }
//        else {
//            DebugLog(@"JSON:\n%@", yelpService.results);
//        }
//    }];

#pragma mark -  Class Extension
#pragma mark -

typedef void (^YPYelpServiceCompletionHandler)(void);

@interface YPYelpService () <NSURLConnectionDelegate>

@property (nonatomic, copy) YPYelpServiceCompletionHandler completionHandler;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *responseData;

@end

@implementation YPYelpService

#pragma mark - Public
#pragma mark -

- (void)searchWithQuery:(NSString *)query location:(NSString *)location withCompletionBlock:(void (^)(void))completionBlock {
    assert(query != nil && ![@"" isEqualToString:query]);
    assert(location != nil && ![@"" isEqualToString:location]);
    assert(completionBlock != nil);
    self.completionHandler = completionBlock;
    
    NSString *encodedQuery = [query encodedURLParameterString];
    NSString *encodedLocation = [location encodedURLParameterString];
    NSString *urlString = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&location=%@",
                           encodedQuery, encodedLocation];
    NSURL *URL = [NSURL URLWithString:urlString];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kYelpConsumerKey secret:kYelpConsumerSecret];
    OAToken *token = [[OAToken alloc] initWithKey:kYelpToken secret:kYelpTokenSecret];
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
    self.responseData = [[NSMutableData alloc] init];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.connection == nil) {
        /* inform the user that the connection failed */
        NSString *errorMessage = [NSString stringWithFormat:@"Error creating connection (%@)", URL];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"CodeTestErrorDomain"
                                             code:100
                                         userInfo:userInfo];
        self.error = error;
        self.completionHandler();
        return;
    }
}

#pragma mark - NSURLConnectionDelegate
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.error = error;
    self.completionHandler();
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                         options:kNilOptions
                                                           error:&error];
    if (error) {
        self.error = error;
    }
    else {
        // determine if the request was a success or failure and then access the data
        if ([json objectForKey:@"error"]) {
            NSDictionary *errorDict = [json objectForKey:@"error"];
            NSString *idString = [errorDict objectForKey:@"id"];
            NSString *text = [errorDict objectForKey:@"text"];
            
            NSString *errorMessage = [NSString stringWithFormat:@"Error accessing Yelp search API: %@: %@", idString, text];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
            self.error = [NSError errorWithDomain:@"YelpServiceErrorDomain"
                                             code:100
                                         userInfo:userInfo];
        }
        
        self.results = json;
    }
    
    self.completionHandler();
}

@end
