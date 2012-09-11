//
//  YPAppDelegate.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "OAuthConsumer.h"

@interface YPAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocation *currentLocation;

@end
