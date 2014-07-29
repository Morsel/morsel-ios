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

@interface MRSLMenuOptionTableViewCell ()

@property (copy, nonatomic) UIColor *pipeOriginalColor;

@end

@implementation MRSLMenuOptionTableViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pipeOriginalColor = self.pipeView.backgroundColor;
    self.optionNameLabel.textColor = [UIColor morselPrimary];
    self.optionNameLabel.font = [UIFont robotoRegularFontOfSize:_optionNameLabel.font.pointSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.pipeView.backgroundColor = (selected) ? [UIColor clearColor] : self.pipeOriginalColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    self.pipeView.backgroundColor = (highlighted) ? [UIColor clearColor] : self.pipeOriginalColor;
}

- (void)setBadgeCount:(NSInteger)badgeCount {
    _badgeCount = badgeCount;
    self.badgeLabelView.count = badgeCount;
    self.badgeLabelView.hidden = (badgeCount == 0);
}

- (void)reset {
    self.pipeView.backgroundColor = self.pipeOriginalColor;
}


#pragma mark - MRSLBaseTableViewCell Methods

- (BOOL)togglable {
    return YES;
}

- (UIColor *)defaultBackgroundColor {
    return [UIColor colorWithWhite:1.0f
                             alpha:0.2f];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [[UIColor morselPrimaryLight] colorWithAlphaComponent:0.05f];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [[UIColor morselMedium] colorWithAlphaComponent:0.05f];
}

@end
