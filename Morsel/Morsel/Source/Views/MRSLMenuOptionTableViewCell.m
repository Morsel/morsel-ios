//
//  MRSLMenuOptionTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 6/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMenuOptionTableViewCell.h"

#import "MRSLBadgeLabelView.h"

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
    self.backgroundColor = (selected) ? [UIColor colorWithWhite:1.f alpha:.4f] : [UIColor clearColor];
}

- (void)reset {
    self.pipeView.backgroundColor = self.pipeOriginalColor;
}

@end
