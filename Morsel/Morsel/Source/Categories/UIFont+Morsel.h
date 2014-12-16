//
//  UIFont+Morsel.h
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Morsel)

+ (UIFont *)primaryBoldFontOfSize:(CGFloat)fontSize;
+ (UIFont *)primaryItalicsFontOfSize:(CGFloat)fontSize;
+ (UIFont *)primaryRegularFontOfSize:(CGFloat)fontSize;
+ (UIFont *)primaryLightFontOfSize:(CGFloat)fontSize;
+ (UIFont *)primaryLightItalicFontOfSize:(CGFloat)fontSize;
+ (UIFont *)secondaryRegularFontOfSize:(CGFloat)fontSize;
+ (UIFont *)secondaryBoldFontOfSize:(CGFloat)fontSize;

+ (UIFont *)preferredPrimaryFontForTextStyle:(NSString *)textStyle;
+ (UIFont *)preferredSecondaryFontForTextStyle:(NSString *)textStyle;

@end
