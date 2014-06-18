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

+ (UIFont *)robotoSlabRegularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"RobotoSlab-Regular"
                           size:fontSize];
}

+ (UIFont *)robotoLightFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Roboto-Light"
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

@end
