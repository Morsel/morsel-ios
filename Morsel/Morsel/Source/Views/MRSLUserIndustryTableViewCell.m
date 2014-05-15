//
//  MRSLUserIndustryTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserIndustryTableViewCell.h"

@interface MRSLUserIndustryTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkView;

@end

@implementation MRSLUserIndustryTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.checkmarkView setImage:[UIImage imageNamed:(selected) ? @"icon-circle-check-green" : @"icon-circle-check-gray"]];
}

@end
