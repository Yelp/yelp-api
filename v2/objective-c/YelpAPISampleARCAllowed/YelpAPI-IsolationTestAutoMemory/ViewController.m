//
//  ViewController.m
//  YelpAPI-IsolationTestAutoMemory
//
//  Created by Terry Bu on 11/7/14.
//  Copyright (c) 2014 TerryBuOrganization. All rights reserved.
//

#import "ViewController.h"
#import "YPAPISample.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"
#import "NSURLRequest+OAuth.h"
#import "YourKeysAndTokens.h"
#import <CoreLocation/CoreLocation.h>



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:@"Astoria, NY" completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *term = @"lunch";
            NSString *searchLimit= @"10";
            NSString *address = [[NSString alloc]initWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%f,%f&limit=%@", term, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude, searchLimit];
            
            NSURL *URL = [NSURL URLWithString:address];
            //Some boiler plate code to make with OAuth
            
            OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey secret:kConsumerSecret]; //Generates the key we pass for OAuth
            
            OAToken *token = [[OAToken alloc] initWithKey:kToken secret:kTokenSecret]; //Generates the token we pass for OAuth
            
            id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init]; //Encypts the key & token to send it over the Internet
            
            OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL consumer:consumer token:token realm:nil signatureProvider:provider]; //Makes the URL request for our url with key, token and other info we set
            
            [request prepare]; //OAuth boilerplate
            
            self.responseData = [[NSMutableData alloc] init]; //Allocates the NSData object that will handle our asynchronous request
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //This is the part we make (fire) url request
        }
    }];
    

    

}

#pragma mark NSURLConnection Delegate Methods

- (void) connection:(NSURLConnection* )connection didReceiveResponse:(NSURLResponse *)response {
    //this handler, gets hit ONCE
}

- (void)connection: (NSURLConnection *)connection didReceiveData:(NSData *) data {
    //this handler, gets hit SEVERAL TIMES
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    //Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //this handler gets hit ONCE
    // The request is complete and data has been received
    // You can parse the stuff in your data variable now or do whatever you want
    
    NSLog(@"connection finished");
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[self.responseData length]);
    
    //Convert your responseData object
    NSError *myError = nil;
    NSDictionary *responseDataInNSDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"%@", responseDataInNSDictionary);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
