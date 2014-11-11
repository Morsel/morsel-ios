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

+ (UIFont *)robotoSlabItalicsFontOfSize:(CGFloat)fontSize {
    //  Since there's no italics font for Roboto Slab, just use Regular. When fonts change in
    //  the future this should be updated w/ the new italics font
    return [UIFont robotoSlabRegularFontOfSize:fontSize];
}

+ (UIFont *)robotoSlabRegularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"RobotoSlab-Regular"
                           size:fontSize];
}

+ (UIFont *)robotoLightFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Roboto-Light"
                           size:fontSize];
}

+ (UIFont *)robotoLightItalicFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Roboto-LightItalic"
                           size:fontSize];
}

+ (UIFont *)robotoRegularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Roboto-Regular"
                           size:fontSize];
}

+ (UIFont *)robotoBoldFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Roboto-Bold"
                           size:fontSize];
}

+ (UIFont *)preferredRobotoFontForTextStyle:(NSString *)textStyle {
    CGFloat fontSize = 16.f;
    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;

    if ([contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
        fontSize = 8.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {
        fontSize = 9.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
        fontSize = 10.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {
        fontSize = 12.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {
        fontSize = 14.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
        fontSize = 16.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
        fontSize = 20.f;
    }

    // choose the font weight
    if ([textStyle isEqualToString:UIFontTextStyleHeadline]) {
        fontSize += 2.f;
        return [UIFont robotoSlabBoldFontOfSize:fontSize];
    } else if ([textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        return [UIFont robotoSlabBoldFontOfSize:fontSize];
    } else if ([textStyle isEqualToString:UIFontTextStyleCaption1]) {
        fontSize -= 2.f;
        return [UIFont robotoSlabRegularFontOfSize:fontSize];
    }  else if ([textStyle isEqualToString:UIFontTextStyleCaption2]) {
        fontSize -= 2.f;
        return [UIFont robotoSlabRegularFontOfSize:fontSize];
    } else {
        return [UIFont robotoSlabRegularFontOfSize:fontSize];
    }
}

@end
