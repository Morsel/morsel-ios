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

- (void)awakeFromNib {
    [super awakeFromNib];

    [self addDefaultBorderForDirections:(MRSLBorderNorth|MRSLBorderSouth)];
    [self setTextColor:[UIColor morselDefaultTextColor]];
    [self setBackgroundColor:[UIColor morselDefaultTextFieldBackgroundColor]];
    [self setPlaceholderColor:[UIColor morselDefaultPlaceholderTextColor]];

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) {
        self.textContainerInset = UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
    } else {
        //  top/bottom don't work correctly on iOS < 7
        self.contentInset = UIEdgeInsetsMake(0.0f,kPadding,0.0f,kPadding);
    }
}

@end
