//
//  UIFont+Morsel.m
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIFont+Morsel.h"

@implementation UIFont (Myriad)

+ (UIFont *)helveticaNeueLTStandardThinCondensedFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeueLTStd-ThCn"
                           size:fontSize];
}

+ (UIFont *)helveticaNeueLTStandardCondensedFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeueLTStd-Cn"
                           size:fontSize];
}

+ (UIFont *)helveticaNeueLTStandardCondensedObliqueFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"HelveticaNeueLTStd-CnO"
                           size:fontSize];
}

+ (UIFont *)helveticaLightFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Helvetica-Light"
                           size:fontSize];
}

@end
