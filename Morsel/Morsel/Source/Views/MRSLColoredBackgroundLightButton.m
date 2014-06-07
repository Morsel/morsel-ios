//
//  MorselLargeButton.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLColoredBackgroundLightButton.h"

@implementation MRSLColoredBackgroundLightButton

- (void)setUp {
    [self addObserver:self
           forKeyPath:@"highlighted"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [self addObserver:self
           forKeyPath:@"selected"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [self addObserver:self
           forKeyPath:@"enabled"
              options:NSKeyValueObservingOptionNew
              context:NULL];

    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateNormal];
    [self setTitleColor:[UIColor darkGrayColor]
               forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateSelected];

    [self.titleLabel setFont:[UIFont robotoLightFontOfSize:self.titleLabel.font.pointSize]];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];

    [self setTitleColor:([backgroundColor isEqual:self.originalBackgroundColor]) ? [UIColor whiteColor] : [UIColor lightGrayColor]
               forState:UIControlStateSelected];

    if (![backgroundColor isEqual:self.originalBackgroundColor] &&
        ![backgroundColor isEqual:self.highlightedBackgroundColor]) {
        [self setupColors];
    }
}

- (void)setupColors {
    if (self.backgroundColor == nil) return;
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
        alpha = .4f;

        self.highlightedBackgroundColor = [UIColor colorWithHue:hue
                                                     saturation:saturation
                                                     brightness:brightness
                                                          alpha:alpha];
    } else {
        self.highlightedBackgroundColor = [UIColor darkGrayColor];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (self.highlighted && self.enabled && !_allowsToggle) {
        self.backgroundColor = self.highlightedBackgroundColor;
    } else if (self.highlighted && self.enabled && _allowsToggle) {
        self.backgroundColor = self.originalBackgroundColor;
    } else if (!self.highlighted && self.enabled && (self.selected && _allowsToggle)) {
        self.backgroundColor = self.originalBackgroundColor;
    } else if (!self.highlighted && self.enabled && (!self.selected && _allowsToggle)) {
        self.backgroundColor = self.highlightedBackgroundColor;
    } else if (!self.enabled) {
        self.backgroundColor = [UIColor lightGrayColor];
    } else {
        self.backgroundColor = self.originalBackgroundColor;
    }

    [self setNeedsDisplay];
}

- (void)setValue:(id)value
          forKey:(NSString *)key {
    if ([key isEqualToString:@"allowsToggle"]) {
        self.allowsToggle = [value boolValue];
        [self setBackgroundColor:self.selected ? self.originalBackgroundColor : self.highlightedBackgroundColor];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)dealloc {
    @try {
        [self removeObserver:self
                  forKeyPath:@"highlighted"];
        [self removeObserver:self
                  forKeyPath:@"selected"];
        [self removeObserver:self
                  forKeyPath:@"enabled"];
    }
    @catch (NSException *exception) {
        DDLogError(@"Key paths not observed and removal attempt failed: %@", exception);
    }
}

@end
