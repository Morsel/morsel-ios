//
//  MRSLColoredBackgroundToggleButton.m
//  Morsel
//
//  Created by Javier Otero on 6/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSegmentButton.h"

@interface MRSLSegmentButton ()

@property (nonatomic) BOOL colorSet;

@end

@implementation MRSLSegmentButton

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

    [self setTitleColor:[UIColor lightGrayColor]
               forState:UIControlStateNormal];
    [self setTitleColor:[UIColor morselLight]
               forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateSelected];

    [self.titleLabel setFont:[UIFont robotoRegularFontOfSize:self.titleLabel.font.pointSize]];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    if (!_colorSet) {
        self.colorSet = YES;
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
    if (self.highlighted && self.enabled && !self.allowsToggle) {
        self.backgroundColor = self.highlightedBackgroundColor;
    } else if (self.highlighted && self.enabled && self.allowsToggle) {
        self.backgroundColor = self.originalBackgroundColor;
    } else if (!self.highlighted && self.enabled && (self.selected && self.allowsToggle)) {
        self.backgroundColor = self.originalBackgroundColor;
    } else if (!self.highlighted && self.enabled && (!self.selected && self.allowsToggle)) {
        self.backgroundColor = [UIColor whiteColor];
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
        [self setBackgroundColor:self.selected ? self.originalBackgroundColor : [UIColor whiteColor]];
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
