//
//  MRSLMenuOptionTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 6/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMenuOptionTableViewCell.h"

#import "MRSLBadgeLabelView.h"

@interface MRSLBaseTableViewCell ()

- (UIColor *)defaultBackgroundColor;
- (UIColor *)defaultHighlightedBackgroundColor;
- (UIColor *)defaultSelectedBackgroundColor;

@property (nonatomic) BOOL togglable;

@end

@implementation MRSLMenuOptionTableViewCell

#pragma mark - Instance Methods

- (void)layoutSubviews {
    [super layoutSubviews];
    self.optionNameLabel.textColor = [UIColor morselPrimary];
    self.optionNameLabel.font = [UIFont primaryRegularFontOfSize:_optionNameLabel.font.pointSize];
    [self addBorderWithDirections:MRSLBorderSouth
                      borderColor:[[self defaultBackgroundColor] colorWithAlphaComponent:.8f]];
}

- (void)setBadgeCount:(NSInteger)badgeCount {
    _badgeCount = badgeCount;
    self.badgeLabelView.count = badgeCount;
    self.badgeLabelView.hidden = (badgeCount == 0);
}


#pragma mark - MRSLBaseTableViewCell Methods

- (BOOL)togglable {
    return YES;
}

- (UIColor *)defaultBackgroundColor {
    return [UIColor colorWithWhite:1.f
                             alpha:.4f];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [[UIColor morselMedium] colorWithAlphaComponent:.1f];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [[UIColor morselPrimaryLight] colorWithAlphaComponent:.1f];
}

@end
