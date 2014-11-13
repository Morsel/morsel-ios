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

- (void)layoutSubviews {
    [super layoutSubviews];

    [self addDefaultBorderForDirections:(MRSLBorderNorth|MRSLBorderSouth)];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    // Pushing down placeholder to align with textfield user added text. This only works with 14 point font.
    rect.origin.y += 10.f;
    [[self placeholder] drawInRect:rect
                    withAttributes:@{
                                     NSFontAttributeName : [UIFont robotoLightFontOfSize:self.font.pointSize],
                                     NSForegroundColorAttributeName: [UIColor morselDefaultPlaceholderTextColor]
                                     }];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + kPadding, bounds.origin.y,
                      bounds.size.width - (kPadding * 2.0f), bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
