//
//  YPBaseNibView.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPBaseNibView.h"

#import <MapKit/MapKit.h>

@implementation YPBaseNibView

#pragma mark - Initialization
#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UINib *cellNib = [UINib nibWithNibName:[self nibName] bundle:nil];
    NSArray *items = [cellNib instantiateWithOwner:self options:nil];
    
    for (id item in items) {
        if ([item isKindOfClass:[UIView class]]) {
            if ([item isKindOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView *)item;
                assert(tableView.delegate != nil);
                assert(tableView.dataSource != nil);
            }
            else if ([item isKindOfClass:[MKMapView class]]) {
                MKMapView *mapView = (MKMapView *)item;
                assert(mapView.delegate != nil);
            }
            [self addSubview:(UIView *)item];
        }
    }
}

- (NSString *)nibName {
    return NSStringFromClass([self class]);
}

@end
