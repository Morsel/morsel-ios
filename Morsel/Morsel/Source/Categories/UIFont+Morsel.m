//
//  UIFont+Morsel.m
//  Morsel
//
//  Created by Javier Otero.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIFont+Morsel.h"

@implementation UIFont (Morsel)

+ (UIFont *)primaryBoldFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Lato-Bold"
                           size:fontSize];
}

+ (UIFont *)primaryItalicsFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Lato-BoldItalic"
                           size:fontSize];
}

+ (UIFont *)primaryRegularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Lato-Regular"
                           size:fontSize];
}

+ (UIFont *)primaryLightFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Lato-Light"
                           size:fontSize];
}

+ (UIFont *)primaryLightItalicFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Lato-LightItalic"
                           size:fontSize];
}

+ (UIFont *)secondaryRegularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Merriweather"
                           size:fontSize];
}

+ (UIFont *)secondaryBoldFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Merriweather-Bold"
                           size:fontSize];
}

+ (CGFloat)fontSizeForContent {
    CGFloat fontSize = 16.f;
    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;

    if ([contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
        fontSize = 10.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {
        fontSize = 11.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
        fontSize = 12.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {
        fontSize = 14.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {
        fontSize = 16.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
        fontSize = 18.f;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
        fontSize = 22.f;
    }
    return fontSize;
}

+ (UIFont *)preferredPrimaryFontForTextStyle:(NSString *)textStyle {
    CGFloat fontSize = [UIFont fontSizeForContent];

    // choose the font weight
    if ([textStyle isEqualToString:UIFontTextStyleHeadline]) {
        fontSize += 2.f;
        return [UIFont primaryBoldFontOfSize:fontSize];
    } else if ([textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        return [UIFont primaryBoldFontOfSize:fontSize];
    } else if ([textStyle isEqualToString:UIFontTextStyleCaption1]) {
        fontSize -= 2.f;
        return [UIFont primaryRegularFontOfSize:fontSize];
    }  else if ([textStyle isEqualToString:UIFontTextStyleCaption2]) {
        fontSize -= 2.f;
        return [UIFont primaryRegularFontOfSize:fontSize];
    } else {
        return [UIFont primaryRegularFontOfSize:fontSize];
    }
}

+ (UIFont *)preferredSecondaryFontForTextStyle:(NSString *)textStyle {
    CGFloat fontSize = [UIFont fontSizeForContent];

    // choose the font weight
    if ([textStyle isEqualToString:UIFontTextStyleHeadline]) {
        fontSize += 2.f;
        return [UIFont secondaryBoldFontOfSize:fontSize];
    } else if ([textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        return [UIFont secondaryBoldFontOfSize:fontSize];
    } else if ([textStyle isEqualToString:UIFontTextStyleCaption1]) {
        fontSize -= 2.f;
        return [UIFont secondaryRegularFontOfSize:fontSize];
    }  else if ([textStyle isEqualToString:UIFontTextStyleCaption2]) {
        fontSize -= 2.f;
        return [UIFont secondaryRegularFontOfSize:fontSize];
    } else {
        return [UIFont secondaryRegularFontOfSize:fontSize];
    }
}

@end
