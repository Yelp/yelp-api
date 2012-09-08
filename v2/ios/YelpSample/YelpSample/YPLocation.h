//
//  YPLocation.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YPLocation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (copy, nonatomic) NSURL *imageURL;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
