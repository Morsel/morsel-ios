//
//  MRSLTagStatsCell.m
//  Morsel
//
//  Created by Javier Otero on 4/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTagStatsNameCell.h"

@implementation MRSLTagStatsNameCell

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self displaySelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self displaySelectedState:selected];
}

- (void)displaySelectedState:(BOOL)selected {
    self.backgroundColor = (selected) ? [UIColor morselRed] : [UIColor whiteColor];
    self.nameLabel.textColor = (selected) ? [UIColor whiteColor] : [UIColor morselRed];
}

@end
