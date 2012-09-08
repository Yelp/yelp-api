//
//  YPBurstAnnotationView.m
//  YelpSample
//
//  Created by Brennan Stehling on 9/7/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YPBurstAnnotationView.h"

#import "UIImage+BBlock.h"

#pragma mark -  Class Extension
#pragma mark -

@interface YPBurstAnnotationView ()

@property (nonatomic, retain) UIImageView *imageView;

@end

@implementation YPBurstAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier location:(YPLocation *)location {
    if ( (self = [super initWithAnnotation: annotation reuseIdentifier: reuseIdentifier]) ) {
        // initialize and add views

        UIImage *burstImage = [self burstImage];
        CGSize imageSize = [burstImage size];
        self.imageView = [[UIImageView alloc] initWithImage:burstImage];
        
        self.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
        self.imageView.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
        
        self.clipsToBounds = FALSE;
        
        [self addSubview:self.imageView];
    }
    
    return self;
}

- (void)prepareForReuse {
    // TODO finish
//    self.imageView = nil;
}

- (UIImage *)burstImage {
//    UIImage *image = [UIImage imageWithIdentifier:@"BurstAnnoationImage" forSize:CGSizeMake(40.0, 40.0) andDrawingBlock:^{
//    }];
//    
//    return [UIImage imageWithImage:image scaledToSize:CGSizeMake(40.0, 40.0)];
    return [UIImage imageNamed:@"BurstAnnotation.png"];
}

@end
