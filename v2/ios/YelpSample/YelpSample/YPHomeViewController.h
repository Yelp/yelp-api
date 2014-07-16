//
//  YPHomeViewController.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YPHomeViewController : UIViewController

@property (strong, nonatomic) CLLocation *latestCurrentLocation;

@end
