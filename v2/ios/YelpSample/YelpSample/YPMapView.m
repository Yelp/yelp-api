//
//  YPMapView.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPMapView.h"

#import <MapKit/MapKit.h>

#import "YPBurstAnnotationView.h"

#define kAnnotationViewReuseIdentifier      @"YelpBurstAnnotation"

#pragma mark -  Class Extension
#pragma mark -

@interface YPMapView () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) YPLocation *currentSelectedLocation;

@end

@implementation YPMapView

#pragma mark - Initialization
#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // ensure outlets are connected
    assert(self.mapView != nil);
    assert(self.mapView.delegate == self);
    
    self.mapView.frame = self.frame;
    
    // ensure it is sized properly
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.width = self.frame.size.width;
    mapFrame.size.height = self.frame.size.height;
    self.mapView.frame = mapFrame;
}

#pragma mark - Public Methods
#pragma mark -

- (void)setMapAnnotations:(NSArray *)locations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:locations];
}

- (void)setSelectedLocation:(YPLocation *)location {
    self.currentSelectedLocation = location;
    
    // TODO finish (focus on that annotation)
}

#pragma mark - MKMapViewDelegate
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    
    YPLocation *location = [self locationForAnnotation:annotation];
    
    if (location != nil) {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationViewReuseIdentifier];
        if (!annotationView) {
            annotationView = [[YPBurstAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationViewReuseIdentifier location:location];
        } else {
            annotationView.annotation = annotation;
        }
        
        assert([annotationView isKindOfClass:[YPBurstAnnotationView class]]);
        
        annotationView.canShowCallout = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    YPLocation *location = [self locationForAnnotationView:view];
    if (location != nil) {
        self.currentSelectedLocation = location;
        
        if ([self.delegate respondsToSelector:@selector(mapView:didSelectLocation:)]) {
            [self.delegate mapView:self didSelectLocation:location];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    self.currentSelectedLocation = nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    YPLocation *location = [self locationForAnnotationView:view];
    
    DebugLog(@"location: %@", location);
    
    // TODO finish (push detail view)
}

//- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView NS_AVAILABLE(NA, 4_0);
//- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView NS_AVAILABLE(NA, 4_0);
//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation NS_AVAILABLE(NA, 4_0);
//- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error NS_AVAILABLE(NA, 4_0);

#pragma mark - Private
#pragma mark -

- (YPLocation *)locationForAnnotation:(id<MKAnnotation>)annotation {
    YPLocation *location = nil;
    
    if ([annotation isKindOfClass:[YPLocation class]]) {
        location = (YPLocation *)annotation;
    }
    
    return location;
}

- (YPLocation *)locationForAnnotationView:(MKAnnotationView *)annotationView {
    return [self locationForAnnotation:annotationView.annotation];
}

@end
