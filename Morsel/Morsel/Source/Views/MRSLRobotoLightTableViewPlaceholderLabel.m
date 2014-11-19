//
//  MRSLRobotoLightTableViewPlaceholderLabel.m
//  Morsel
//
//  Created by Javier Otero on 11/11/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLRobotoLightTableViewPlaceholderLabel.h"

@implementation MRSLRobotoLightTableViewPlaceholderLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = UIEdgeInsetsMake(0.f, 20.f, 0.f, 20.f);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
