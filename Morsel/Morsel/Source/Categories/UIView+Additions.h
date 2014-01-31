//
//  UIView+Additions.h
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (void)addBorderWithColor:(UIColor *)color
                  andWidth:(CGFloat)width;
- (void)addStandardCorners;
- (void)addCornersWithRadius:(CGFloat)radius;
- (void)addStandardShadow;
- (void)addStandardShadowWithColor:(UIColor *)shadowColor;

- (void)removeBorder;
- (void)removeStandardShadow;

- (void)addGradientWithTopColor:(UIColor *)topColor
                 andBottomColor:(UIColor *)bottomColor;

- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setX:(CGFloat)anX;
- (void)setY:(CGFloat)aY;

- (CGFloat)getX;
- (CGFloat)getY;
- (CGFloat)getHeight;
- (CGFloat)getWidth;

- (UIImage *)imageByRenderingView;

@end
