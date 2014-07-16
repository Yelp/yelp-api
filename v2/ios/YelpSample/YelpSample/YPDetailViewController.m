//
//  YPDetailViewController.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPDetailViewController.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ONNetworking.h"
#import "YPBurstAnnotationView.h"

#define kAnnotationViewReuseIdentifier      @"YelpBurstAnnotation"


@interface YPDetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *businessPhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *reviewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *neighborhoodLabel;
@property (weak, nonatomic) IBOutlet UILabel *snippetTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *openInYelpButton;

- (IBAction)openInYelpButtonTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;

- (double)distanceInMiles:(double)meters;

@end

@implementation YPDetailViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // ensure required properties are set
    assert(self.location != nil);
    assert(self.mapView != nil);
    assert(self.mapView.delegate == self);
    
    [self roundCornersForView:self.businessPhotoImageView borderColor:[UIColor darkGrayColor] borderWidth:1.0 cornerRadius:5.0];
    [self roundCornersForView:self.mapView borderColor:[UIColor whiteColor] borderWidth:1.0 cornerRadius:5.0];
    
    self.distanceLabel.text = @"--";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self populateOutlets];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)openInYelpButtonTapped:(id)sender {
    // yelp:///biz/{id}
    if ([self isYelpInstalled]) {
        NSURL *businessURL = [NSURL URLWithString:[NSString stringWithFormat:@"yelp:///biz/%@", self.location.businessId]];
        [[UIApplication sharedApplication] openURL:businessURL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yelp"
                                                        message:@"You must have Yelp installed to check in."
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString( @"OK", @"" )
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

- (IBAction)shareButtonTapped:(id)sender {
}

#pragma mark - MKMapViewDelegate
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    
    YPLocation *location = [YPLocation locationForAnnotation:annotation];
    
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocationDistance distance = [YPLocation distanceFromUserLocation:userLocation.location toYelpLocation:self.location];
    [self updateDistance:distance];
    [self repositionMap:TRUE];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    DebugLog(@"Error: %@", error);
    self.distanceLabel.text = @"--";
}

#pragma mark - Private Methods
#pragma mark -

- (void)populateOutlets {
    self.titleLabel.text = self.location.name;
    self.reviewCountLabel.text = [NSString stringWithFormat:@"%i reviews", self.location.reviewCount];
    self.categoryLabel.text = self.location.category;
    self.addressLabel.text = self.location.address;
    self.neighborhoodLabel.text = self.location.neighborhood;
    
    CGRect snippetFrame = self.snippetTextLabel.frame;
    CGFloat snippetHeight = [self heightForFont:self.snippetTextLabel.font withText:self.location.snippetText withMaxSize:CGSizeMake(snippetFrame.size.width,100.0)];
    snippetFrame.size.height = snippetHeight;
    self.snippetTextLabel.text = self.location.snippetText;
    self.snippetTextLabel.frame = snippetFrame;
    
    assert(self.mapView.delegate == self);
    
    [self.mapView addAnnotation:self.location];
    self.mapView.showsUserLocation = TRUE;
    self.mapView.userInteractionEnabled = FALSE;
    [self repositionMap:FALSE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        if (self.mapView.showsUserLocation) {
            CLLocationDistance distance = [YPLocation distanceFromUserLocation:self.mapView.userLocation.location toYelpLocation:self.location];
            [self updateDistance:distance];
            [self repositionMap:TRUE];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self repositionMap:TRUE];
    });
    
    [self downloadImages];
}

- (void)downloadImages {
    NSMutableArray *URLs = [NSMutableArray array];
    if (self.location.imageURL != nil) {
        [URLs addObject:self.location.imageURL];
    }
    if (self.location.ratingImageURLLarge != nil) {
        [URLs addObject:self.location.ratingImageURLLarge];
    }
    
    self.businessPhotoImageView.hidden = TRUE;
    self.ratingImageView.hidden = TRUE;
    
    for (NSURL *url in URLs) {
        ONDownloadItem *downloadItem = [[ONDownloadItem alloc] initWithURL:url];
        ONDownloadOperation *operation = [[ONDownloadOperation alloc] initWithDownloadItem:downloadItem];
        [operation setCompletionHandler:^(NSData *data, NSError *error) {
            if (error != nil) {
                DebugLog(@"Error: %@", error);
            }
            else {
                UIImage *image = [UIImage imageWithData:data];
                if ([url isEqual:self.location.imageURL]) {
                    self.businessPhotoImageView.image = image;
                    self.businessPhotoImageView.hidden = FALSE;
                }
                else if ([url isEqual:self.location.ratingImageURLLarge]) {
                    self.ratingImageView.image = image;
                    self.ratingImageView.hidden = FALSE;
                }
            }
        }];
        
        [[ONNetworkManager sharedInstance] addOperation:operation];
    }
}

- (CGFloat)heightForFont:(UIFont *)font withText:(NSString *)text withMaxSize:(CGSize)maxSize {
    CGSize size = [text sizeWithFont:font
                   constrainedToSize:maxSize
                       lineBreakMode:UILineBreakModeTailTruncation];
    return size.height;
}

- (void)roundCornersForView:(UIView *)view borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    [[view layer] setBorderColor:[borderColor CGColor]];
    [[view layer] setBorderWidth:borderWidth];
    [[view layer] setCornerRadius:cornerRadius];
    [view setClipsToBounds: YES];
}

- (double)distanceInMiles:(double)meters {
    return meters * 0.000621371192237334;
}

- (void)updateDistance:(CLLocationDistance)distance {
    // distance is in meters
    DebugLog(@"updateDistance: %f", distance);
    double miles = [self distanceInMiles:distance];
    if (miles > 99.0) {
        self.distanceLabel.text = @"99+ mi";
    }
    else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%2.1f mi", miles];
    }
}

- (void)repositionMap:(BOOL)animated {
    if (self.mapView.annotations.count == 0) {
        return;
    }
    
    MKMapRect mapRect = MKMapRectNull;
    
    // annotations should include Yelp location and user location if they are near each other
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            CLLocationDistance distance = [YPLocation distanceFromUserLocation:self.mapView.userLocation.location toYelpLocation:self.location];
            double miles = [self distanceInMiles:distance];
            DebugLog(@"miles: %2.1f", miles);
            if (miles > 5.0) {
                continue;
            }
        }
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.25, 0.25);
        if (MKMapRectIsNull(mapRect)) {
            mapRect = pointRect;
        } else {
            mapRect = MKMapRectUnion(mapRect, pointRect);
        }
    }
    
    if (!MKMapRectIsNull(mapRect)) {
        [self.mapView setVisibleMapRect:mapRect animated:animated];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        self.mapView.userInteractionEnabled = FALSE;
    });
}

- (BOOL)isYelpInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp:"]];
}

@end
