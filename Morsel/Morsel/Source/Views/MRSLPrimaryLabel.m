//
//  MorselStandardLabel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPrimaryLabel.h"

@implementation MRSLPrimaryLabel

- (id)initWithFrame:(CGRect)frame
        andFontSize:(CGFloat)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont primaryLightFontOfSize:fontSize];
        [self setTextColor:[UIColor morselDefaultTextColor]];
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont primaryLightFontOfSize:16.f];
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
    [self setFont:[UIFont primaryLightFontOfSize:self.font.pointSize]];
}

- (UIFont *)obliqueFont {
    return [UIFont primaryLightItalicFontOfSize:self.font.pointSize];
}

- (void)setOblique:(BOOL)oblique {
    _oblique = oblique;
    if (oblique) {
        [self setFont:[[self obliqueFont] fontWithSize:self.font.pointSize]];
    } else {
        [self setUp];
    }
}

@end
