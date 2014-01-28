//
//  MorselThinButton.m
//  Morsel
//
//  Created by Javier Otero on 1/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselThinButton.h"

@implementation MorselThinButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    [self.titleLabel setFont:[UIFont helveticaNeueLTStandardThinCondensedFontOfSize:self.titleLabel.font.pointSize]];
}

@end
