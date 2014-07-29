//
//  UIColor+Morsel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//
//  NOTE: Should match http://style.eatmorsel.com/?p=atoms-colors

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "UIColor+Morsel.h"

@implementation UIColor (Morsel)

#pragma mark - Morsel Style Guide

+ (UIColor *)morselPrimary {
    return UIColorFromRGB(0xE96144);
}

+ (UIColor *)morselSecondary {
    return UIColorFromRGB(0x51BA3D);
}

+ (UIColor *)morselTertiary {
    return UIColorFromRGB(0xF0CF69);
}

+ (UIColor *)morselBackground {
    return UIColorFromRGB(0xFFFFFF);
}

+ (UIColor *)morselBackgroundDark {
    return UIColorFromRGB(0x030000);
}

+ (UIColor *)morselLight {
    return UIColorFromRGB(0xE2DDD7);
}

+ (UIColor *)morselMedium {
    return UIColorFromRGB(0x93A491);
}

+ (UIColor *)morselDark {
    return UIColorFromRGB(0x394038);
}

+ (UIColor *)morselLightOff {
    return UIColorFromRGB(0xF3F1EF);
}

+ (UIColor *)morselPrimaryLight {
    return UIColorFromRGB(0xEE8872);
}

+ (UIColor *)morselPrimaryDark {
    return UIColorFromRGB(0x87392B);
}

+ (UIColor *)morselPrimaryBright {
    return UIColorFromRGB(0xD62600);
}

+ (UIColor *)morselSecondaryBright {
    return UIColorFromRGB(0x31961C);
}

+ (UIColor *)morselLightest {
    return UIColorFromRGB(0xFBFBFA);
}

+ (UIColor *)morselOffWhite {
    return UIColorFromRGB(0xF9F7F7);
}


#pragma mark - Defined Colors

+ (UIColor *)morselDefaultBackgroundColor {
    return [UIColor morselLightOff];
}

+ (UIColor *)morselDefaultBorderColor {
    return [UIColor morselLight];
}

+ (UIColor *)morselDefaultCellBackgroundColor {
    return [UIColor morselBackground];
}

+ (UIColor *)morselDefaultNavigationBarBackgroundColor {
    return [UIColor morselLightest];
}

+ (UIColor *)morselDefaultSectionHeaderBackgroundColor {
    return [UIColor morselLightest];
}

+ (UIColor *)morselDefaultTextFieldBackgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)morselDefaultTextColor {
    return [UIColor morselDark];
}

+ (UIColor *)morselDefaultPlaceholderTextColor {
    return [[UIColor morselDefaultTextColor] colorWithBrightness:1.2f];
}

+ (UIColor *)morselDefaultToolbarBackgroundColor {
    return [UIColor morselLightest];
}

+ (UIColor *)morselValidColor {
    return [UIColor greenColor];
}

+ (UIColor *)morselInvalidColor {
    return [UIColor redColor];
}


#pragma mark - Instance Methods

- (UIColor *)colorWithBrightness:(CGFloat)brightness {
    CGFloat originalHue, originalSaturation, originalBrightness, originalAlpha;
    if ([self getHue:&originalHue saturation:&originalSaturation brightness:&originalBrightness alpha:&originalAlpha]) {
        return [UIColor colorWithHue:originalHue
                          saturation:originalSaturation
                          brightness:MIN(originalBrightness * brightness, 1.0)
                               alpha:originalAlpha];
    }

    //  Grayscale colors crap out on getHue:, fallback to getWhite:
    CGFloat originalWhite;
    if ([self getWhite:&originalWhite alpha:&originalAlpha]) {
        return [UIColor colorWithWhite:MIN(originalWhite * brightness, 1.0)
                                 alpha:originalAlpha];
    }

    return nil;
}

@end
