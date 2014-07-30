//
//  MRSLToggleKeywordTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLToggleKeywordTableViewCell.h"

#import "MRSLKeyword.h"
#import "MRSLUser.h"

@interface MRSLBaseTableViewCell ()

- (UIColor *)defaultBackgroundColor;

@end

@interface MRSLToggleKeywordTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *keywordCheckmarkView;
@property (weak, nonatomic) IBOutlet UILabel *keywordNameLabel;

@end

@implementation MRSLToggleKeywordTableViewCell

- (void)awakeFromNib {
    if (_keyword) [self displayContent];
}

- (void)setKeyword:(MRSLKeyword *)keyword {
    if (_keyword != keyword) {
        _keyword = keyword;

        [self displayContent];
    }
}

- (void)displayContent {
    self.keywordNameLabel.text = _keyword.name;
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated {
    [super setSelected:selected
              animated:animated];
    self.keywordCheckmarkView.image = [UIImage imageNamed:(selected) ? @"icon-circle-check-green" : @"icon-circle-check-gray"];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [UIColor morselLight];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [self defaultBackgroundColor];
}

@end
