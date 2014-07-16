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

@property (copy, nonatomic) NSString *businessId;
@property (strong, nonatomic) NSURL *imageURL;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *snippetText;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *stateCode;
@property (copy, nonatomic) NSString *countryCode;
@property (copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSString *neighborhood;
@property (assign, nonatomic) NSUInteger reviewCount;
@property (strong, nonatomic) NSURL *ratingImageURL;
@property (strong, nonatomic) NSURL *ratingImageURLLarge;
@property (strong, nonatomic) NSURL *ratingImageURLSmall;
@property (strong, nonatomic) NSURL *mobileURL;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

+ (CLLocationDistance)distanceFromUserLocation:(CLLocation *)userLocation toYelpLocation:(YPLocation *)yelpLocation;
+ (YPLocation *)locationForAnnotation:(id<MKAnnotation>)annotation;
+ (YPLocation *)locationForAnnotationView:(MKAnnotationView *)annotationView;

@end
