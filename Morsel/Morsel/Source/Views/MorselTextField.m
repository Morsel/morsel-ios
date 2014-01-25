//
//  MorselTextField.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselTextField.h"

@implementation MorselTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.font = [UIFont helveticaLightFontOfSize:14.f];
    }
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
#warning Deprecated in iOS 7. Make friendly.
    [[UIColor morselLightContent] setFill];
    [[self placeholder] drawInRect:rect
                          withFont:[UIFont helveticaLightFontOfSize:14.f]];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 15.f, 15.f);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 15.f, 15.f);
}

@end
