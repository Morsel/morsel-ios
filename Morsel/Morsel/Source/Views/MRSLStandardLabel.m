//
//  MorselStandardLabel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStandardLabel.h"

@implementation MRSLStandardLabel

- (id)initWithFrame:(CGRect)frame
        andFontSize:(CGFloat)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont robotoLightFontOfSize:fontSize];
        [self setTextColor:[UIColor morselDefaultTextColor]];
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont robotoLightFontOfSize:16.f];
        [self setTextColor:[UIColor morselDefaultTextColor]];
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
