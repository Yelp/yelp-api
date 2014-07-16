//
//  YPLocation.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPLocation.h"

#pragma mark -  Class Extension
#pragma mark -

@interface YPLocation ()

@property (strong, nonatomic) NSDictionary *dictionary;

@end

@implementation YPLocation

- (void)populateWithDictionary:(NSDictionary *)dictionary {
    DebugLog(@"dictionary:\n%@", dictionary);
    self.dictionary = dictionary;
    
    self.businessId = [dictionary objectForKey:@"id"];
    self.name = [dictionary objectForKey:@"name"];
    self.snippetText = [dictionary objectForKey:@"snippet_text"];
    self.imageURL = [NSURL URLWithString:[dictionary objectForKey:@"image_url"]];
    self.reviewCount = [[dictionary objectForKey:@"review_count"] intValue];
    self.ratingImageURL = [NSURL URLWithString:[dictionary objectForKey:@"rating_img_url"]];
    self.ratingImageURLLarge = [NSURL URLWithString:[dictionary objectForKey:@"rating_img_url_large"]];
    self.ratingImageURLSmall = [NSURL URLWithString:[dictionary objectForKey:@"rating_img_url_small"]];
    
    NSArray *categories = [dictionary objectForKey:@"categories"];
    NSMutableArray *categoryNames = [NSMutableArray array];
    for (NSArray *category in categories) {
        [categoryNames addObject:[category objectAtIndex:0]];
    }
    if (categories.count > 0) {
        self.category = [categoryNames componentsJoinedByString:@", "];
    }
    
    // location
    NSDictionary *locationDictionary = [dictionary objectForKey:@"location"];
    
    self.city = [locationDictionary objectForKey:@"city"];
    self.stateCode = [locationDictionary objectForKey:@"state_code"];
    self.countryCode = [locationDictionary objectForKey:@"country_code"];
    
    NSArray *neighborhoods = [locationDictionary objectForKey:@"neighborhoods"];
    if (neighborhoods.count > 0) {
        self.neighborhood = [neighborhoods objectAtIndex:0];
    }

    NSArray *addresses = [locationDictionary objectForKey:@"address"];
    if (addresses.count == 1) {
        self.address = [addresses objectAtIndex:0];
    }
    else if (addresses.count == 2) {
        self.address = [NSString stringWithFormat:@"%@, %@", [addresses objectAtIndex:0], [addresses objectAtIndex:1]];
    }
    else if (addresses.count == 3) {
        self.address = [NSString stringWithFormat:@"%@, %@, %@", [addresses objectAtIndex:0], [addresses objectAtIndex:1], [addresses objectAtIndex:2]];
    }
    NSDictionary *coordinateDictionary = [locationDictionary objectForKey:@"coordinate"];
    NSNumber *latitude = [coordinateDictionary objectForKey:@"latitude"];
    NSNumber *longitude = [coordinateDictionary objectForKey:@"longitude"];
    
    self.title = self.name;
    self.subtitle = self.address;
        
    self.coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
}

+ (CLLocationDistance)distanceFromUserLocation:(CLLocation *)userLocation toYelpLocation:(YPLocation *)yelpLocation {
    CLLocation *destLocation = [[CLLocation alloc] initWithLatitude:yelpLocation.coordinate.latitude longitude:yelpLocation.coordinate.longitude];
    CLLocationDistance difference = [userLocation distanceFromLocation:destLocation];
    
    return difference;
}

+ (YPLocation *)locationForAnnotation:(id<MKAnnotation>)annotation {
    YPLocation *location = nil;
    
    if ([annotation isKindOfClass:[YPLocation class]]) {
        location = (YPLocation *)annotation;
    }
    
    return location;
}

+ (YPLocation *)locationForAnnotationView:(MKAnnotationView *)annotationView {
    return [YPLocation locationForAnnotation:annotationView.annotation];
}

@end
