//
//  UIImage+Watermark.m
//  Morsel
//
//  Created by Marty Trzpit on 8/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIImage+Watermark.h"

@implementation UIImage (Watermark)

+ (UIImage *)MRSL_applyWatermarkToImage:(UIImage *)image {
    UIImage *backgroundImage = image;
    UIImage *watermarkImage = [UIImage imageNamed:@"graphic-morsel-watermark"];

    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [watermarkImage drawInRect:CGRectMake(10.0f, backgroundImage.size.height - watermarkImage.size.height - 10.0f, watermarkImage.size.width, watermarkImage.size.height)];

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
