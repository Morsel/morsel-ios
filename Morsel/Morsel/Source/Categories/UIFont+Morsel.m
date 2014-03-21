//
//  UIFont+Morsel.m
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIFont+Morsel.h"

@implementation UIFont (Morsel)

+ (UIFont *)robotoSlabBoldFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"RobotoSlab-Bold"
                           size:fontSize];
}

+ (UIFont *)robotoCondensedRegularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"RobotoCondensed-Regular"
                           size:fontSize];
}

+ (UIFont *)robotoCondensedItalicFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"RobotoCondensed-Italic"
                           size:fontSize];
}

+ (UIFont *)robotoCondensedLightFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"RobotoCondensed-Light"
                           size:fontSize];
}

+ (UIFont *)helveticaLightFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Helvetica-Light"
                           size:fontSize];
}

+ (UIFont *)helveticaLightObliqueFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Helvetica-LightOblique"
                           size:fontSize];
}

@end
