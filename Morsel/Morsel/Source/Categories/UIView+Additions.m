//
//  UIView+Additions.m
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@implementation UIView (Additions)

#pragma mark - Instance Methods

#pragma mark - Effect Methods

- (void)setBorderWithColor:(UIColor *)color
                  andWidth:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void)addStandardCorners {
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    self.layer.opaque = YES;
    self.layer.needsDisplayOnBoundsChange = NO;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)addCornersWithRadius:(CGFloat)radius {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    self.layer.opaque = YES;
    self.layer.needsDisplayOnBoundsChange = NO;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)addStandardShadow {
    [self addStandardShadowWithColor:[UIColor blackColor]];
}

- (void)addStandardShadowWithColor:(UIColor *)shadowColor; {
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOffset = CGSizeMake(2.f, 2.f);
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
