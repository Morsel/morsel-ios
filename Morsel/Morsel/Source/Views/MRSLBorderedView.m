//
//  MRSLBorderedView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBorderedView.h"

@implementation MRSLBorderedView

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.borderDirections rangeOfString:@"North"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderNorth];
    }
    if ([self.borderDirections rangeOfString:@"South"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderSouth];
    }
    if ([self.borderDirections rangeOfString:@"East"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderEast];
    }
    if ([self.borderDirections rangeOfString:@"West"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderWest];
    }
}

@end
