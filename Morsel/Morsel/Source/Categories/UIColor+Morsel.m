//
//  UIColor+Morsel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIColor+Morsel.h"

@implementation UIColor (Morsel)

+ (UIColor *)morselRed
{
    return [UIColor colorWithRed:233.f/255.f
                           green:97.f/255.f
                            blue:68.f/255.f
                           alpha:1.f];
}

+ (UIColor *)morselGreen
{
    return [UIColor colorWithRed:81.f/255.f
                           green:186.f/255.f
                            blue:61.f/255.f
                           alpha:1.f];
}

+ (UIColor *)morselYellow
{
    return [UIColor colorWithRed:240.f/255.f
                           green:207.f/255.f
                            blue:105.f/255.f
                           alpha:1.f];
}

+ (UIColor *)morselUserInterface
{
    return [UIColor colorWithRed:226.f/255.f
                           green:221.f/255.f
                            blue:215.f/255.f
                           alpha:1.f];
}

+ (UIColor *)morselDarkContent
{
    return [UIColor colorWithRed:57.f/255.f
                           green:64.f/255.f
                            blue:56.f/255.f
                           alpha:1.f];
}

+ (UIColor *)morselLightContent
{
    return [UIColor colorWithRed:147.f/255.f
                           green:165.f/255.f
                            blue:144.f/255.f
                           alpha:1.f];
}

@end