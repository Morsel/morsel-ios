//
//  MRSLColoredBackgroundLightButton.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLColoredBackgroundLightButton.h"

@implementation MRSLColoredBackgroundLightButton

- (void)setUp {
    [super setUp];
    
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
    [self setTitleColor:[UIColor morselOffWhite]
               forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateSelected];

    [self.titleLabel setFont:[UIFont primaryLightFontOfSize:self.titleLabel.font.pointSize]];
    self.accessibilityLabel = self.titleLabel.text;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];

    [self setTitleColor:([backgroundColor isEqual:self.originalBackgroundColor]) ? [UIColor whiteColor] : [UIColor lightGrayColor]
               forState:UIControlStateSelected];

    if (![backgroundColor isEqual:self.originalBackgroundColor] &&
        ![backgroundColor isEqual:self.highlightedBackgroundColor]) {
        [self setupColors];
    }

    [self setBorderWithColor:[self.backgroundColor colorWithBrightness:0.9f]
                    andWidth:MRSLBorderDefaultWidth];
}


- (void)setupColors {
    if (self.backgroundColor == nil) return;
    self.originalBackgroundColor = self.backgroundColor;
    self.highlightedBackgroundColor = [self.backgroundColor colorWithBrightness:0.8f];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (self.highlighted) {
        if (self.enabled) {
            if (_allowsToggle) {
                self.backgroundColor = self.originalBackgroundColor;
            } else {
                self.backgroundColor = self.highlightedBackgroundColor;
            }
            
        }
    } else if (self.enabled) {
        if (_allowsToggle) {
            if (self.selected) {
                self.backgroundColor = self.originalBackgroundColor;
            } else {
                self.backgroundColor = self.highlightedBackgroundColor;
            }
        } else {
            self.backgroundColor = self.originalBackgroundColor;
        }
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
        DDLogError(@"\n\n\n\n\n\nKey paths not observed and removal attempt failed: %@", exception);
    }
}

@end
