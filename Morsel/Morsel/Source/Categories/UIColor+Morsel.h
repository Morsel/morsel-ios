//
//  UIColor+Morsel.h
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Morsel)

#pragma mark - Morsel Style Guide

+ (UIColor *)morselPrimary;
+ (UIColor *)morselSecondary;
+ (UIColor *)morselTertiary;
+ (UIColor *)morselBackground;
+ (UIColor *)morselBackgroundDark;
+ (UIColor *)morselLight;
+ (UIColor *)morselMedium;
+ (UIColor *)morselDark;
+ (UIColor *)morselLightOff;
+ (UIColor *)morselPrimaryLight;
+ (UIColor *)morselPrimaryDark;
+ (UIColor *)morselPrimaryBright;
+ (UIColor *)morselSecondaryBright;
+ (UIColor *)morselLightest;
+ (UIColor *)morselOffWhite;


#pragma mark - Defined Colors

+ (UIColor *)morselDefaultBackgroundColor;


#pragma mark - Misc

+ (UIColor *)morselRed;
+ (UIColor *)morselGreen;
+ (UIColor *)morselUserInterface;
+ (UIColor *)morselDarkContent;
+ (UIColor *)morselLightContent;
+ (UIColor *)morselLightOffColor;
+ (UIColor *)morselPlaceholderColor;

@end
