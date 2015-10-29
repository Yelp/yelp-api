//
//  ViewController.h
//  YelpAPI-IsolationTestAutoMemory
//
//  Created by Terry Bu on 11/7/14.
//  Copyright (c) 2014 TerryBuOrganization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *responseData;

@end

