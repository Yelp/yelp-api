//
//  YPMapView.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YPBaseNibView.h"
#import "YPLocation.h"

@protocol YPMapViewDelegate;

@interface YPMapView : YPBaseNibView

@property (assign, nonatomic) IBOutlet id<YPMapViewDelegate> delegate;
@property (weak, nonatomic) NSArray *locations;

- (void)setMapAnnotations:(NSArray *)locations;
- (void)setSelectedLocation:(YPLocation *)location;

@end

@protocol YPMapViewDelegate <NSObject>

@optional

- (void)mapView:(YPMapView *)mapView didSelectLocation:(YPLocation *)location;

@end
