//
//  MRSLPlaceCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceCollectionViewCell.h"

#import "MRSLPlace.h"

@interface MRSLPlaceCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *placeIconView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCityStateLabel;

@end

@implementation MRSLPlaceCollectionViewCell

- (void)setPlace:(MRSLPlace *)place {
    if (_place != place) {
        _place = place;

        self.placeNameLabel.text = _place.name;
        self.placeCityStateLabel.text = [_place fullAddress];
    }
}

@end
