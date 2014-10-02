//
//  MRSLPlaceholderTextView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

static CGFloat kPadding = MRSLDefaultPadding;

#import "MRSLPlaceholderTextView.h"

@implementation MRSLPlaceholderTextView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self removeBorder];
    [self addDefaultBorderForDirections:(MRSLBorderAll)];
    [self setTextColor:[UIColor morselDefaultTextColor]];
    [self setBackgroundColor:[UIColor morselDefaultTextFieldBackgroundColor]];
    [self setPlaceholderColor:[UIColor morselDefaultPlaceholderTextColor]];
    self.textContainerInset = UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
}

@end
