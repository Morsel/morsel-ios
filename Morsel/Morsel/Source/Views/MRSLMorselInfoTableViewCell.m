//
//  MRSLMorselInfoTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 8/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselInfoTableViewCell.h"

@interface MRSLMorselInfoTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation MRSLMorselInfoTableViewCell

#pragma mark - Private Methods

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setSelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectedState:selected];
}

- (void)setSelectedState:(BOOL)selected {
    self.arrowImageView.image = [UIImage imageNamed:(selected) ? @"icon-arrow-accessory-white" : @"icon-arrow-accessory-red"];
}

@end
