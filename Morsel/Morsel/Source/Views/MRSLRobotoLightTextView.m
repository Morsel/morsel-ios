//
//  MRSLRobotoLightTextView.m
//  Morsel
//
//  Created by Javier Otero on 4/16/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

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
}

@end