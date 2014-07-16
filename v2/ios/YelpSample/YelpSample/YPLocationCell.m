//
//  YPLocationCell.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPLocationCell.h"

#import <CoreLocation/CoreLocation.h>

#import "YPAppDelegate.h"
#import "ONNetworking.h"

#pragma mark -  Class Extension
#pragma mark -

@interface YPLocationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) YPLocation *location;

// observers are retained by the system
@property (assign, nonatomic) id locationUpdatedNotificationObserver;

@end

@implementation YPLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public Methods
#pragma mark -

- (void)customizeForLocation:(YPLocation *)location {
    self.location = location;
    
    self.nameLabel.text = location.title;
    self.addressLabel.text = [NSString stringWithFormat:@"%@ - %@", location.address, location.category];
    
    CLLocationDistance meters = [YPLocation distanceFromUserLocation:[self currentLocation] toYelpLocation:location];
    double miles = meters * 0.000621371192237334;
    self.distanceLabel.text = [NSString stringWithFormat:@"%2.1f mi", miles];
    
    ONDownloadItem *downloadItem = [[ONDownloadItem alloc] initWithURL:location.imageURL];
    ONDownloadOperation *operation = [[ONDownloadOperation alloc] initWithDownloadItem:downloadItem];
    [operation setCompletionHandler:^(NSData *data, NSError *error) {
        if (error != nil) {
            DebugLog(@"Error: %@", error);
        }
        else {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
    }];
    
    [[ONNetworkManager sharedInstance] addOperation:operation];
}

- (CLLocation *)currentLocation {
    YPAppDelegate *appDelegate = (YPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return appDelegate.currentLocation;
}

@end
