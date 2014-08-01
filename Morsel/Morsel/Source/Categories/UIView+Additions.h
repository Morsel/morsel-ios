//
//  UIView+Additions.h
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, MRSLBorderDirection) {
    MRSLBorderNone = 0,
    MRSLBorderNorth = 1 << 0,
    MRSLBorderEast  = 1 << 1,
    MRSLBorderSouth = 1 << 2,
    MRSLBorderWest  = 1 << 3,
    MRSLBorderAll   = 0xFFFF
};

static const CGFloat MRSLBorderDefaultWidth = 0.5f;
static const CGFloat MRSLDefaultPadding = 10.0f;
static const CGFloat MRSLRoundedCornerDefaultRadius = 2.0f;
static const CGFloat MRSLDefaultAnimationDuration = 0.2f;

@interface UIView (Additions)

+ (void)animateWithDefaultDurationAnimations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDefaultDurationAnimations:(void (^)(void))animations;

- (void)addCenteredSubview:(UIView *)subviewToAddAndCenter withOffset:(CGPoint)offset;
- (void)addCenteredSubview:(UIView *)subviewToAddAndCenter;

- (void)setBorderWithColor:(UIColor *)color
                  andWidth:(CGFloat)width;

/**
 Creates borders at the specified directions
 */
- (CAShapeLayer *)addBorderWithDirections:(MRSLBorderDirection)borderDirections borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (CAShapeLayer *)addBorderWithDirections:(MRSLBorderDirection)borderDirections borderColor:(UIColor *)borderColor;

- (CAShapeLayer *)addDefaultBorderForDirections:(MRSLBorderDirection)borderDirections;


- (void)setRoundedCornerRadius:(CGFloat)radius;
- (void)setDefaultRoundedCornerRadius;
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
