//
//  MRSLAlignedButton.m
//  Morsel
//
//  Created by Javier Otero on 8/18/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAlignedButton.h"

@implementation MRSLAlignedButton

- (UIEdgeInsets)alignmentRectInsets {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) return UIEdgeInsetsZero;
    return UIEdgeInsetsMake(0, -9.f, 0, 0);
}

@end
