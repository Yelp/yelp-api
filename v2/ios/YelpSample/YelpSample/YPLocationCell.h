//
//  YPLocationCell.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YPLocation.h"

@interface YPLocationCell : UITableViewCell

- (void)customizeForLocation:(YPLocation *)location;

@end
