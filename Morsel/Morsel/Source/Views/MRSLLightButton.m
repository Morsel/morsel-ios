//
//  MorselStandardButton.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLLightButton.h"

static CGFloat kPadding = MRSLDefaultPadding;

@implementation MRSLLightButton

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
    [self.titleLabel setFont:[UIFont robotoLightFontOfSize:self.titleLabel.font.pointSize]];
    [self setDefaultRoundedCornerRadius];
}

- (void)setFittedTitleForAllStates:(NSString *)title {
    if ([title isEqualToString:self.titleLabel.text]) return;

    [self setTitle:title
                 forState:UIControlStateNormal];
    [self sizeToFit];
    //  Assure height is never less than 30
    if ([self getHeight] < 30.0f) {
        [self setHeight:30.0f];
    }
    [self setWidth:[self getWidth] + (kPadding * 2.0f)];
}

@end
