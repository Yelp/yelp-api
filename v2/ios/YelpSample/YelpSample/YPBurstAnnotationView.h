//
//  YPBurstAnnotationView.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "YPLocation.h"

@interface YPBurstAnnotationView : MKAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier location:(YPLocation *)location;

//+ (NSString *)reuseIdentifierForAnnotation:(id <MKAnnotation>)annotation location:(YPLocation *)location;

@end
