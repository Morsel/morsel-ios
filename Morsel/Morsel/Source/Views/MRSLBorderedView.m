//
//  MRSLBorderedView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBorderedView.h"

@implementation MRSLBorderedView

- (void)awakeFromNib {
    [super awakeFromNib];
    if (![self.borderDirection isKindOfClass:[NSString class]]) self.borderDirection = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (![self.borderDirection isKindOfClass:[NSString class]]) return;
    if ([self.borderDirection rangeOfString:@"North"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderNorth];
    }
    if ([self.borderDirection rangeOfString:@"South"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderSouth];
    }
    if ([self.borderDirection rangeOfString:@"East"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderEast];
    }
    if ([self.borderDirection rangeOfString:@"West"].location != NSNotFound) {
        [self addDefaultBorderForDirections:MRSLBorderWest];
    }
}

- (void)setValue:(id)value
          forKey:(NSString *)key {
    if ([key isEqualToString:@"borderDirections"]) {
        self.borderDirection = value;
    } else {
        [super setValue:value forKey:key];
    }
}

@end
