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
    [self setTextColor:[UIColor morselDefaultTextColor]];
    [self setBackgroundColor:[UIColor morselDefaultTextFieldBackgroundColor]];
    [self setPlaceholderColor:[UIColor morselDefaultPlaceholderTextColor]];
    self.textContainerInset = UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeBorder];
        [self addDefaultBorderForDirections:(MRSLBorderAll)];
    });
}

@end
