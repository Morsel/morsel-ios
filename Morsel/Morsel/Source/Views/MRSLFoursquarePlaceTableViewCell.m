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

@end
