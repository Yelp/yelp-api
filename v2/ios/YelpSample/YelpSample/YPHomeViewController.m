//
//  YPHomeViewController.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPHomeViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "YPLocation.h"
#import "YPMapView.h"
#import "YPListView.h"
#import "YPYelpService.h"
#import "YPDetailViewController.h"

#define kPreviousSearchLocation             @"PreviousSearchLocation"
#define kPreviousSearchQuery                @"PreviousSearchQuery"

@interface YPHomeViewController () <YPMapViewDelegate, YPListViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *queryTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet YPMapView *mapView;
@property (weak, nonatomic) IBOutlet YPListView *listView;
@property (weak, nonatomic) IBOutlet UIButton *yelpDevelopersButton;

@property (strong, nonatomic) NSString *searchLocation;
@property (strong, nonatomic) NSString *searchQuery;

@property (strong, nonatomic) YPLocation *currentSelectedLocation;

- (IBAction)segmentedControlValueChanged:(id)sender;
- (IBAction)yelpDevelopersButtonTapped:(id)sender;

@property (strong, nonatomic) NSArray *locations;

@end

@implementation YPHomeViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // ensure the content is set within the container frame
    CGRect contentFrame = self.containerView.frame;
    contentFrame.origin.x = 0.0;
    contentFrame.origin.y = 0.0;
    self.listView.frame = contentFrame;
    self.mapView.frame = contentFrame;
    
    UIColor *yelpRed = [UIColor colorWithRed: 0.72 green: 0.09 blue: 0.05 alpha: 1];
    self.navigationController.navigationBar.tintColor = yelpRed;
    self.topView.backgroundColor = yelpRed;
    self.segmentedControl.tintColor = yelpRed;
    self.yelpDevelopersButton.backgroundColor = yelpRed;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([@"" isEqualToString:self.locationTextField.text] && [@"" isEqualToString:self.queryTextField.text]) {
        NSString *previousSearchLocation = [[NSUserDefaults standardUserDefaults] stringForKey:kPreviousSearchLocation];
        NSString *previousSearchQuery = [[NSUserDefaults standardUserDefaults] stringForKey:kPreviousSearchQuery];
        
        if (previousSearchLocation && previousSearchQuery) {
            self.locationTextField.text = previousSearchLocation;
            self.queryTextField.text = previousSearchQuery;
        }
    }
    
    [self updateViewForLocation:self.locationTextField.text withQuery:self.queryTextField.text];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"HomeToDetail" isEqualToString:segue.identifier] && [segue.destinationViewController isKindOfClass:[YPDetailViewController class]]) {
        YPDetailViewController *detailVC = (YPDetailViewController *)segue.destinationViewController;
        detailVC.location = self.currentSelectedLocation;
    }
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)segmentedControlValueChanged:(id)sender {
    DebugLog(@"Segmented Control Value Changed: %i", self.segmentedControl.selectedSegmentIndex);
    [self updateContentForSelectedSegmentIndex];
}

- (IBAction)yelpDevelopersButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.yelp.com/developers/"]];
}
#pragma mark - YPMapViewDelegate
#pragma mark -

- (void)mapView:(YPMapView *)mapView didSelectLocation:(YPLocation *)location {
    self.currentSelectedLocation = location;
    [self performSegueWithIdentifier:@"HomeToDetail" sender:self];
}

#pragma mark - YPListViewDelegate
#pragma mark -

- (void)listView:(YPListView *)mapView didSelectLocation:(YPLocation *)location {
    self.currentSelectedLocation = location;
    [self performSegueWithIdentifier:@"HomeToDetail" sender:self];
}

#pragma mark - UITextFieldDelegate
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DebugLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    
    if (self.locationTextField.text != nil ) {
        DebugLog(@"Setting previous location: %@", self.locationTextField.text);
        [[NSUserDefaults standardUserDefaults] setObject:self.locationTextField.text forKey:kPreviousSearchLocation];
    }
    if (self.queryTextField.text != nil ) {
        DebugLog(@"Setting previous query: %@", self.queryTextField.text);
        [[NSUserDefaults standardUserDefaults] setObject:self.queryTextField.text forKey:kPreviousSearchQuery];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateViewForLocation:self.locationTextField.text withQuery:self.queryTextField.text];
    
    return TRUE;
}

#pragma mark - Private
#pragma mark -

- (void)updateContentForSelectedSegmentIndex {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.mapView.hidden = FALSE;
        self.listView.hidden = TRUE;
    }
    else {
        self.listView.hidden = FALSE;
        self.mapView.hidden = TRUE;
    }
}

- (void)updateViewForLocation:(NSString *)location withQuery:(NSString *)query {
    // do not repeat the same search
    if (location != nil && [location isEqualToString:self.searchLocation] && query != nil && [query isEqualToString:self.searchQuery]) {
        if (self.locations.count > 0) {
            return;
        }
    }
    // do not run with empty values
    if (location == nil || [@"" isEqualToString:location] || query == nil || [@"" isEqualToString:query]) {
        return;
    }
    
    self.searchLocation = location;
    self.searchQuery = query;
    
    YPYelpService *yelpService = [[YPYelpService alloc] init];
    [yelpService searchWithQuery:query location:location withCompletionBlock:^{
        if (yelpService.error) {
            DebugLog(@"Error: %@: %@", [yelpService.error localizedFailureReason], [yelpService.error localizedDescription]);
        }
        else {
            //            DebugLog(@"JSON:\n%@", yelpService.results);
            
            NSMutableArray *locations = [NSMutableArray array];
            NSArray *businesses = [yelpService.results objectForKey:@"businesses"];
            for (NSDictionary *businessDictionary in businesses) {
                YPLocation *location = [[YPLocation alloc] init];
                [location populateWithDictionary:businessDictionary];
                [locations addObject:location];
            }
            
            self.locations = locations;
            [self.mapView setMapAnnotations:self.locations];
            [self.listView setListItems:self.locations];
            
            DebugLog(@"There are %i locations.", self.locations.count);
        }
    }];
}

@end
