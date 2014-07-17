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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.optionNameLabel.textColor = (selected) ? [UIColor morselRed] : [UIColor morselDarkContent];
    self.optionNameLabel.font = (selected) ? [UIFont robotoBoldFontOfSize:_optionNameLabel.font.pointSize] : [UIFont robotoLightFontOfSize:_optionNameLabel.font.pointSize];
    self.pipeView.backgroundColor = (selected) ? [UIColor clearColor] : self.pipeOriginalColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    self.optionNameLabel.textColor = (highlighted) ? [UIColor whiteColor] : (self.togglable && self.selected ? [UIColor morselRed] : [UIColor morselDarkContent]);
    self.optionNameLabel.font = (highlighted) ? [UIFont robotoBoldFontOfSize:_optionNameLabel.font.pointSize] : (self.togglable && self.selected ? [UIFont robotoBoldFontOfSize:_optionNameLabel.font.pointSize] : [UIFont robotoLightFontOfSize:_optionNameLabel.font.pointSize]);
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
    return [UIColor whiteColor];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [UIColor morselRed];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [UIColor morselLightOff];
}

@end
