//
//  YPHomeViewController.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPHomeViewController.h"

#import "YPMapView.h"
#import "YPListView.h"
#import "YPYelpService.h"

@interface YPHomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet YPMapView *mapView;
@property (weak, nonatomic) IBOutlet YPListView *listView;
@property (weak, nonatomic) IBOutlet UIButton *yelpDevelopersButton;

- (IBAction)segmentedControlValueChanged:(id)sender;
- (IBAction)yelpDevelopersButtonTapped:(id)sender;

@property (strong, nonatomic) NSArray *locations;

@end

@implementation YPHomeViewController

#pragma mark - View Lifecycle
#pragma mark -
@synthesize containerView = _containerView;

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
    
    YPYelpService *yelpService = [[YPYelpService alloc] init];
    [yelpService searchWithQuery:@"pizza" location:@"San Francisco" withCompletionBlock:^{
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

@end
