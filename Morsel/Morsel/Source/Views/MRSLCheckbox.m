//
//  MRSLCheckbox.m
//  Morsel
//
//  Created by Marty Trzpit on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCheckbox.h"

@implementation MRSLCheckbox

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.titleLabel setFont:[UIFont robotoLightFontOfSize:self.titleLabel.font.pointSize]];
    [self setCheckAlignment:M13CheckboxAlignmentLeft];
    [self setFlat:YES];
    [self setStrokeWidth:1.f];
    [self setRadius:0.f];
    [self setStrokeColor:[UIColor morselPrimary]];
    [self setCheckColor:[UIColor morselPrimary]];
}

@end
