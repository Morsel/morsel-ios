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
