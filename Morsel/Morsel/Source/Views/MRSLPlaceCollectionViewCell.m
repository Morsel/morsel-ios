//
//  MRSLPlaceCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceCollectionViewCell.h"

#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLPlaceCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *placeIconView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCityStateLabel;

@end

@implementation MRSLPlaceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self setBackgroundColor:[UIColor morselDefaultCellBackgroundColor]];
}

- (void)setPlace:(MRSLPlace *)place {
    if (_place != place) {
        _place = place;
        [self populateContent];
    }
}

- (void)populateContent {
    self.placeNameLabel.text = _place.name;
    if (_place.title) {
        self.placeCityStateLabel.text = _place.title;
    } else {
        self.placeCityStateLabel.text = [_place fullAddress];
    }
    CGSize subSize = [_placeCityStateLabel.text sizeWithFont:_placeCityStateLabel.font constrainedToSize:CGSizeMake([_placeCityStateLabel getWidth], CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    [self.placeCityStateLabel setHeight:subSize.height];
    [self.placeCityStateLabel setY:[_placeNameLabel getY] + [_placeNameLabel getHeight]];
}

@end
