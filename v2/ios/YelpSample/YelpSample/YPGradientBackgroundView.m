//
//  YPGradientBackgroundView.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPGradientBackgroundView.h"

@implementation YPGradientBackgroundView
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* gradientColor = [UIColor colorWithRed: 0.92 green: 0.92 blue: 0.92 alpha: 1];
    UIColor* lightGrayGradientColor = [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 1];
    
    //// Gradient Declarations
    NSArray* lightGrayGradientColors = [NSArray arrayWithObjects:
                                        (id)gradientColor.CGColor,
                                        (id)[UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1].CGColor,
                                        (id)lightGrayGradientColor.CGColor, nil];
    CGFloat lightGrayGradientLocations[] = {0, 0.89, 1};
    CGGradientRef lightGrayGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)lightGrayGradientColors, lightGrayGradientLocations);
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 1, rect.size.width, rect.size.height)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, lightGrayGradient, CGPointMake(160, 1), CGPointMake(160, 45), 0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(lightGrayGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
