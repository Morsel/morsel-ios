//
//  UIView+Additions.m
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@implementation UIView (Additions)

#pragma mark - Class Methods

+ (void)animateWithDefaultDurationAnimations:(void (^)(void))animations {
    [UIView animateWithDuration:MRSLDefaultAnimationDuration
                     animations:animations];
}

#pragma mark - Instance Methods

- (void)addCenteredSubview:(UIView *)subviewToAddAndCenter withOffset:(CGPoint)offset {
    [self addSubview:subviewToAddAndCenter];
    [subviewToAddAndCenter setCenter:CGPointMake(self.center.x + offset.x, self.center.y + offset.y)];
}

- (void)addCenteredSubview:(UIView *)subviewToAddAndCenter {
    [self addCenteredSubview:subviewToAddAndCenter
                  withOffset:CGPointZero];
}

#pragma mark - Effect Methods

- (void)setBorderWithColor:(UIColor *)color
                  andWidth:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (CAShapeLayer *)addBorderWithDirections:(MRSLBorderDirection)borderDirections borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    [self.layer addSublayer:borderLayer];

    UIBezierPath *path = [[UIBezierPath alloc] init];

    if (borderDirections & MRSLBorderNorth) {
        CGFloat yPoint = borderWidth * 0.5f;
        [path moveToPoint:CGPointMake(0.0f, yPoint)];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), yPoint)];
    }

    if (borderDirections & MRSLBorderWest) {
        CGFloat xPoint = borderWidth * 0.5f;
        [path moveToPoint:CGPointMake(xPoint, 0.0f)];
        [path addLineToPoint:CGPointMake(xPoint, CGRectGetMaxY(self.bounds))];
    }

    if (borderDirections & MRSLBorderSouth) {
        CGFloat yPoint = CGRectGetMaxY(self.bounds) - (borderWidth * 0.5f);
        [path moveToPoint:CGPointMake(0.0f, yPoint)];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), yPoint)];
    }

    if (borderDirections & MRSLBorderEast) {
        CGFloat xPoint = CGRectGetMaxX(self.bounds) - (borderWidth * 0.5f);
        [path moveToPoint:CGPointMake(xPoint, 0.0f)];
        [path addLineToPoint:CGPointMake(xPoint, CGRectGetMaxY(self.bounds))];
    }

    borderLayer.frame = self.bounds;
    borderLayer.path = path.CGPath;

    borderLayer.strokeColor = borderColor.CGColor;
    borderLayer.lineWidth = borderWidth;
    
    return borderLayer;
}

- (CAShapeLayer *)addBorderWithDirections:(MRSLBorderDirection)borderDirections borderColor:(UIColor *)borderColor {
    return [self addBorderWithDirections:borderDirections
                             borderWidth:MRSLBorderDefaultWidth
                             borderColor:borderColor];
}

- (CAShapeLayer *)addDefaultBorderForDirections:(MRSLBorderDirection)borderDirections {
    return [self addBorderWithDirections:borderDirections
                             borderColor:[UIColor morselDefaultBorderColor]];
}

- (void)setRoundedCornerRadius:(CGFloat)radius {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    self.layer.opaque = YES;
    self.layer.needsDisplayOnBoundsChange = NO;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setDefaultRoundedCornerRadius {
    [self setRoundedCornerRadius:MRSLRoundedCornerDefaultRadius];
}

- (void)addStandardShadow {
    [self addStandardShadowWithColor:[UIColor blackColor]];
}

- (void)addShadowWithOpacity:(float)opacity
                   andRadius:(CGFloat)radius
                   withColor:(UIColor *)color {
    [self addStandardShadowWithColor:color];
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
}

- (void)addStandardShadowWithColor:(UIColor *)shadowColor; {
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = .9f;
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOffset = CGSizeMake(.0f, .0f);
    self.layer.masksToBounds = NO;
    self.layer.needsDisplayOnBoundsChange = NO;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
}

- (void)removeBorder {
    self.layer.borderWidth = 0.f;
    self.layer.borderColor = nil;
}

- (void)removeStandardShadow {
    self.layer.shadowColor = nil;
    self.layer.shadowOpacity = 0.f;
    self.layer.shadowRadius = 0.f;
    self.layer.shadowOffset = CGSizeMake(0.f, 0.f);
    self.layer.shouldRasterize = NO;
}

- (void)addGradientWithTopColor:(UIColor *)topColor
                 andBottomColor:(UIColor *)bottomColor {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
    [self.layer insertSublayer:gradient
                       atIndex:0];
}

#pragma mark - Setter Methods

- (void)setHeight:(CGFloat)height {
    CGRect tFrame = [self frame];
    tFrame.size.height = height;
    [self setFrame:tFrame];
}

- (void)setWidth:(CGFloat)width {
    CGRect tFrame = [self frame];
    tFrame.size.width = width;
    [self setFrame:tFrame];
}

- (void)setX:(CGFloat)anX {
    CGRect tFrame = [self frame];
    tFrame.origin.x = anX;
    [self setFrame:tFrame];
}

- (void)setY:(CGFloat)aY {
    CGRect tFrame = [self frame];
    tFrame.origin.y = aY;
    [self setFrame:tFrame];
}

#pragma mark - Getter Methods

- (CGFloat)getX {
    return self.frame.origin.x;
}

- (CGFloat)getY {
    return self.frame.origin.y;
}

- (CGFloat)getHeight {
    return self.frame.size.height;
}

- (CGFloat)getWidth {
    return self.frame.size.width;
}

#pragma mark - Graphics Methods

- (UIImage *)imageByRenderingView {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, [UIScreen mainScreen].scale);

    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultingImage;
}

@end
