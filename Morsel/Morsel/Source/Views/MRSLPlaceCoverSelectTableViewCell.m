//
//  MRSLPlaceCoverSelectTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 6/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceCoverSelectTableViewCell.h"

#import "MRSLPlace.h"

@interface MRSLPlaceCoverSelectTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkView;

@end

@implementation MRSLPlaceCoverSelectTableViewCell

- (void)setPlace:(MRSLPlace *)place {
    if (_place != place) {
        _place = place;
        
        self.nameLabel.text = _place.name;
        self.cityStateLabel.text = [_place fullAddress];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.checkmarkView setImage:[UIImage imageNamed:(selected) ? @"icon-circle-check-green" : @"icon-circle-check-gray"]];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [UIColor morselDefaultCellBackgroundColor];
}

@end
