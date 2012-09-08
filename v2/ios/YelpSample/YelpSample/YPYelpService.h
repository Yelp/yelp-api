//
//  CTYelpService.h
//  CodeTest
//
//  Created by Brennan Stehling on 9/3/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YPYelpService : NSObject

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSDictionary *results;

- (void)searchWithQuery:(NSString *)query location:(NSString *)location withCompletionBlock:(void (^)(void))completionBlock;

@end
