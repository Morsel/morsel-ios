//
//  MorselTextField.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTextField.h"

@implementation MRSLTextField

- (id)initWithCoder:(NSCoder  *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.font = [UIFont robotoLightFontOfSize:self.font.pointSize];
    }
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    [[UIColor morselLightContent] setFill];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) {
        // Pushing down placeholder to align with textfield user added text. This only works with 14 point font.
        rect.origin.y += 6.f;
    }
    [[self placeholder] drawInRect:rect
                          withFont:[UIFont robotoLightFontOfSize:self.font.pointSize]];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5.f, 5.f);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5.f, 5.f);
}

@end
