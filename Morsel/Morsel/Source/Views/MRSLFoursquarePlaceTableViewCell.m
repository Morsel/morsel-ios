//
//  MRSLFoursquarePlaceTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFoursquarePlaceTableViewCell.h"

#import "MRSLFoursquarePlace.h"

@interface MRSLFoursquarePlaceTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;

@end

@implementation MRSLFoursquarePlaceTableViewCell

#pragma mark - Instance Methods

- (void)setFoursquarePlace:(MRSLFoursquarePlace *)foursquarePlace {
    if (_foursquarePlace != foursquarePlace) {
        _foursquarePlace = foursquarePlace;

        self.nameLabel.text = _foursquarePlace.name;
        self.cityStateLabel.text = [_foursquarePlace fullAddress];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.nameLabel.textColor = (selected) ? [UIColor whiteColor] : [UIColor darkGrayColor];
    self.cityStateLabel.textColor = (selected) ? [UIColor whiteColor] : [UIColor darkGrayColor];
    [self setBackgroundColor:(selected) ? [UIColor morselRed] : [UIColor whiteColor]];
}

@end
