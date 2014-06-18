//
//  MRSLMenuOptionTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 6/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLBadgeLabelView;

@interface MRSLMenuOptionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *optionNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *pipeView;

@property (weak, nonatomic) IBOutlet MRSLBadgeLabelView *badgeLabelView;

- (void)reset;

@end
