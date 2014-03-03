//
//  MorselLargeButton.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselLargeButton.h"

@interface MorselLargeButton ()

@property (nonatomic, strong) UIColor *originalBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;

@end

@implementation MorselLargeButton

- (void)setUp {
    [self addObserver:self
           forKeyPath:@"highlighted"
              options:NSKeyValueObservingOptionNew
              context:NULL];

    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor lightGrayColor]
               forState:UIControlStateDisabled];

    [self.titleLabel setFont:[UIFont helveticaLightFontOfSize:self.titleLabel.font.pointSize]];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];

    if (![backgroundColor isEqual:self.originalBackgroundColor] && ![backgroundColor isEqual:self.highlightedBackgroundColor]) {
        [self setupColors];
    }
}

- (void)setupColors {
    self.originalBackgroundColor = self.backgroundColor;

    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;

    BOOL colorSpaceConverted = [self.originalBackgroundColor getHue:&hue
                                                         saturation:&saturation
                                                         brightness:&brightness
                                                              alpha:&alpha];

    if (colorSpaceConverted) {
        brightness = .2f;

        self.highlightedBackgroundColor = [UIColor colorWithHue:hue
                                                     saturation:saturation
                                                     brightness:brightness
                                                          alpha:alpha];
    } else {
        self.highlightedBackgroundColor = [UIColor darkGrayColor];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.highlighted) {
        self.backgroundColor = self.highlightedBackgroundColor;
    } else {
        self.backgroundColor = self.originalBackgroundColor;
    }

    [self setNeedsDisplay];
}

- (void)dealloc {
    [self removeObserver:self
              forKeyPath:@"highlighted"];
}

@end
