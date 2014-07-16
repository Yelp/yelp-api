//
//  YPListView.h
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YPBaseNibView.h"
#import "YPLocation.h"

@protocol YPListViewDelegate;

@interface YPListView : YPBaseNibView

@property (assign, nonatomic) IBOutlet id<YPListViewDelegate> delegate;
@property (weak, nonatomic) NSArray *locations;

- (void)setListItems:(NSArray *)locations;
- (void)setSelectedLocation:(YPLocation *)location;

@end

@protocol YPListViewDelegate <NSObject>

@optional

- (void)listView:(YPListView *)mapView didSelectLocation:(YPLocation *)location;

@end
