//
//  MRSLStandardTextView.m
//  Morsel
//
//  Created by Javier Otero on 10/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStandardTextView.h"

@implementation MRSLStandardTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - Override

- (void)setUp {
    self.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor morselPrimary],
                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
}

@end
