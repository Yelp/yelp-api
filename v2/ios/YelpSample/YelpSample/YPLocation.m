//
//  YPLocation.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPLocation.h"

@implementation YPLocation

- (void)populateWithDictionary:(NSDictionary *)dictionary {
//    DebugLog(@"dictionary:\n%@", dictionary);
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSString *imageUrl = [dictionary objectForKey:@"image_url"];
    NSDictionary *locationDictionary = [dictionary objectForKey:@"location"];
    NSArray *addresses = [locationDictionary objectForKey:@"address"];
    NSString *address = @"";
    if (addresses.count > 0) {
        address = [addresses objectAtIndex:0];
    }
    NSDictionary *coordinateDictionary = [locationDictionary objectForKey:@"coordinate"];
    NSNumber *latitude = [coordinateDictionary objectForKey:@"latitude"];
    NSNumber *longitude = [coordinateDictionary objectForKey:@"longitude"];
    
    self.title = name;
    self.subtitle = address;
    self.imageURL = [NSURL URLWithString:imageUrl];
    self.coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
}

@end
