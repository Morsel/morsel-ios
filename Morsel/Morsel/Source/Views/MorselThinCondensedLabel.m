//
//  MorselThinCondensedLabel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselThinCondensedLabel.h"

@implementation MorselThinCondensedLabel

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
    [self setFont:[UIFont helveticaNeueLTStandardThinCondensedFontOfSize:self.font.pointSize]];
}

@end
