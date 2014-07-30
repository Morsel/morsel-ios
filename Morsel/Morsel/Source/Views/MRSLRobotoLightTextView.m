//
//  MRSLRobotoLightTextView.m
//  Morsel
//
//  Created by Javier Otero on 4/16/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

static CGFloat kPadding = MRSLDefaultPadding;

#import "MRSLRobotoLightTextView.h"

@implementation MRSLRobotoLightTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    [self setFont:[UIFont robotoLightFontOfSize:self.font.pointSize]];
    [self setTextColor:[UIColor morselDefaultTextColor]];
    [self setBackgroundColor:[UIColor morselDefaultTextFieldBackgroundColor]];

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) {
        self.textContainerInset = UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
    } else {
        //  top/bottom don't work correctly on iOS < 7
        self.contentInset = UIEdgeInsetsMake(0.0f,kPadding,0.0f,kPadding);
    }
}

@end
