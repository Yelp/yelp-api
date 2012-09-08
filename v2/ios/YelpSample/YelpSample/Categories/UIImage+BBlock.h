//
//  UIImage+BBlock.h
//  BBlock
//
//  Created by David Keegan on 3/21/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(BBlock)

/** Returns a `UIImage` rendered with the drawing code in the block. 
This method does not cache the image object. */
+ (UIImage *)imageForSize:(CGSize)size withDrawingBlock:(void(^)())drawingBlock;

/** Returns a cached `UIImage` rendered with the drawing code in the block. 
The `UIImage` is cached in an `NSCache` with the identifier provided. */
+ (UIImage *)imageWithIdentifier:(NSString *)identifier forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock;

/** Returns a `UIImage`  with the new size */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
