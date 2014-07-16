//
//  YPDetailViewController.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YPLocation.h"

@interface YPDetailViewController : UIViewController

@property (strong, nonatomic) YPLocation *location;

@end
