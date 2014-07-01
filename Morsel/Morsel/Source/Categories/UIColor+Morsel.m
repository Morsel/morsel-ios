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


#pragma mark - Misc

+ (UIColor *)morselRed {
    return [UIColor colorWithRed:232.f / 255.f
                           green:97.f / 255.f
                            blue:67.f / 255.f
                           alpha:1.f];
}

+ (UIColor *)morselGreen {
    return [UIColor colorWithRed:81.f / 255.f
                           green:186.f / 255.f
                            blue:61.f / 255.f
                           alpha:1.f];
}

+ (UIColor *)morselUserInterface {
    return [UIColor colorWithRed:251.f / 255.f
                           green:250.f / 255.f
                            blue:250.f / 255.f
                           alpha:1.f];
}

+ (UIColor *)morselDarkContent {
    return [UIColor colorWithRed:57.f / 255.f
                           green:64.f / 255.f
                            blue:56.f / 255.f
                           alpha:1.f];
}

+ (UIColor *)morselLightContent {
    return [UIColor colorWithRed:147.f / 255.f
                           green:165.f / 255.f
                            blue:144.f / 255.f
                           alpha:1.f];
}

+ (UIColor *)morselLightOffColor {
    return [UIColor colorWithRed:243.f / 255.f
                           green:241.f / 255.f
                            blue:239.f / 255.f
                           alpha:1.f];
}

+ (UIColor *)morselPlaceholderColor {
    return [UIColor colorWithRed:170.f / 255.f
                           green:170.f / 255.f
                            blue:170.f / 255.f
                           alpha:1.f];
}

@end
