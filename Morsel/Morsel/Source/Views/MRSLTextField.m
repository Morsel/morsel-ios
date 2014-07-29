//
//  MorselTextField.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

static CGFloat kPadding = MRSLDefaultPadding;

#import "MRSLTextField.h"

@implementation MRSLTextField

- (id)initWithCoder:(NSCoder  *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.font = [UIFont robotoLightFontOfSize:self.font.pointSize];
        self.textColor = [UIColor morselDefaultTextColor];
        self.backgroundColor = [UIColor morselDefaultTextFieldBackgroundColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self addDefaultBorderForDirections:(MRSLBorderNorth|MRSLBorderSouth)];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    [[UIColor morselDefaultPlaceholderTextColor] setFill];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) {
        // Pushing down placeholder to align with textfield user added text. This only works with 14 point font.
        rect.origin.y += 10.f;
    }
    [[self placeholder] drawInRect:rect
                          withFont:[UIFont robotoLightFontOfSize:self.font.pointSize]];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + kPadding, bounds.origin.y,
                      bounds.size.width - (kPadding * 2.0f), bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
