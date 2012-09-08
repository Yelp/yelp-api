//
//  YPListView.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPListView.h"

#import "YPLocation.h"
#import "YPLocationCell.h"

#define kCellName       @"YPLocationCell"

#pragma mark -  Class Extension
#pragma mark -

@interface YPListView () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) YPLocation *currentSelectedLocation;

@end

@implementation YPListView

#pragma mark - Initialization
#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // ensure outlets are connected
    assert(self.tableView != nil);
    assert(self.tableView.dataSource == self);
    assert(self.tableView.delegate == self);
    
    // ensure it is sized properly
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.width = self.frame.size.width;
    tableFrame.size.height = self.frame.size.height;
    self.tableView.frame = tableFrame;
    
    // Register this nib file with cell identifier.
    UINib *cellNib = [UINib nibWithNibName:kCellName bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kCellName];    
}

#pragma mark - Public Methods
#pragma mark -

- (void)setListItems:(NSArray *)locations {
    self.locations = locations;
    [self.tableView reloadData];
}

- (void)setSelectedLocation:(YPLocation *)location {
    // TODO finish
    self.currentSelectedLocation = location;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView dequeueReusableCellWithIdentifier:kCellName];
    
    assert([cell isKindOfClass:[YPLocationCell class]]);
    assert(indexPath.row < self.locations.count);
    
    if ([cell isKindOfClass:[YPLocationCell class]]) {
        YPLocationCell *locationCell = (YPLocationCell *)cell;
        YPLocation *location = [self.locations objectAtIndex:indexPath.row];
        [locationCell customizeForLocation:location];
    }
    
    return (UITableViewCell*)cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO finish
    
    assert(indexPath.row < self.locations.count);
    YPLocation *location = [self.locations objectAtIndex:indexPath.row];
    self.currentSelectedLocation = location;
    
    if ([self.delegate respondsToSelector:@selector(listView:didSelectLocation:)]) {
        [self.delegate listView:self didSelectLocation:location];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

@end
