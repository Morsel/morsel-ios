//
//  MRSLCheckmarkTextTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 8/22/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCheckmarkTextTableViewCell.h"

@interface MRSLCheckmarkTextTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkView;

@end

@implementation MRSLCheckmarkTextTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.checkmarkView setImage:[UIImage imageNamed:(selected) ? @"icon-circle-check-green" : @"icon-circle-check-gray"]];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [UIColor morselDefaultCellBackgroundColor];
}

@end
