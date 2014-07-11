//
//  UIView+Additions.h
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, MRSLBorderDirection) {
    MRSLBorderNone = 0,
    MRSLBorderNorth = 1 << 0,
    MRSLBorderEast  = 1 << 1,
    MRSLBorderSouth = 1 << 2,
    MRSLBorderWest  = 1 << 3
};

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (void)addCenteredSubview:(UIView *)subviewToAddAndCenter withOffset:(CGPoint)offset;
- (void)addCenteredSubview:(UIView *)subviewToAddAndCenter;

- (void)setBorderWithColor:(UIColor *)color
                  andWidth:(CGFloat)width;

/**
 Creates borders at the specified directions
 */
- (CAShapeLayer *)setBorderWithDirections:(MRSLBorderDirection)borderDirections borderWidth:(CGFloat)borderWidth andBorderColor:(UIColor *)borderColor;

- (void)addStandardCorners;
- (void)addCornersWithRadius:(CGFloat)radius;
- (void)addStandardShadow;
- (void)addStandardShadowWithColor:(UIColor *)shadowColor;
- (void)addShadowWithOpacity:(float)opacity
                   andRadius:(CGFloat)radius
                   withColor:(UIColor *)color;

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
