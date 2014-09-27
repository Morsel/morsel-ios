//
//  MRSLPlaceholderTextView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

static CGFloat kPadding = MRSLDefaultPadding;

#import "MRSLPlaceholderTextView.h"

@implementation MRSLPlaceholderTextView

- (void)layoutSubviews {
    [super layoutSubviews];

    [self removeBorder];
    [self addDefaultBorderForDirections:(MRSLBorderAll)];
    [self setTextColor:[UIColor morselDefaultTextColor]];
    [self setBackgroundColor:[UIColor morselDefaultTextFieldBackgroundColor]];
    [self setPlaceholderColor:[UIColor morselDefaultPlaceholderTextColor]];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.textContainerInset = UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
    } else {
        //  top/bottom don't work correctly on iOS < 7
        self.contentInset = UIEdgeInsetsMake(0.0f,kPadding,0.0f,kPadding);
    }
}

@end
