//
//  MRSLToolbarView.m
//  Morsel
//
//  Created by Javier Otero on 7/11/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLToolbar.h"

@interface MRSLToolbar ()

@end

@implementation MRSLToolbar

- (void)awakeFromNib {
    [self addDefaultBorderForDirections:MRSLBorderNorth];
    [self addShadowWithOpacity:0.2f
                     andRadius:0.5f
                     withColor:[UIColor blackColor]];
    [self setBackgroundColor:[UIColor morselDefaultToolbarBackgroundColor]];
}

#pragma mark - Action Methods

- (IBAction)leftButtonSelected {
    if ([self.delegate respondsToSelector:@selector(toolbarDidSelectLeftButton:)]) {
        [self.delegate toolbarDidSelectLeftButton:_leftButton];
    }
}

- (IBAction)rightButtonSelected {
    if ([self.delegate respondsToSelector:@selector(toolbarDidSelectRightButton:)]) {
        [self.delegate toolbarDidSelectRightButton:_rightButton];
    }
}

@end
