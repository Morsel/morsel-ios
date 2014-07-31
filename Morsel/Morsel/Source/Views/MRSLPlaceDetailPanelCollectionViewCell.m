//
//  MRSLPlaceDetailPanelCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceDetailPanelCollectionViewCell.h"

#import "MRSLPlace.h"

@interface MRSLPlaceDetailPanelCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *makeReservationButton;

@end

@implementation MRSLPlaceDetailPanelCollectionViewCell

#pragma mark - Instance Methods

- (void)setPlace:(MRSLPlace *)place {
    if (_place != place) {
        _place = place;

        self.nameLabel.text = _place.name;
        self.addressLabel.text = [_place fullAddress];
        BOOL hideMenuButton = ![_place hasMenuLink];
        self.viewMenuButton.hidden = hideMenuButton;
        BOOL hideReservationButton = ![_place hasReservationLink];
        self.makeReservationButton.hidden = hideReservationButton;

        if (hideMenuButton && !hideReservationButton) {
            //  Reposition the reservation button
            [self.makeReservationButton setFrame:self.viewMenuButton.frame];
        }
    }
}

#pragma mark - Action Methods

- (IBAction)viewMenu {
    if ([self.delegate respondsToSelector:@selector(placeDetailPanelDidSelectMenu)]) {
        [self.delegate placeDetailPanelDidSelectMenu];
    }
}

- (IBAction)makeReservation {
    if ([self.delegate respondsToSelector:@selector(placeDetailPanelDidSelectReservation)]) {
        [self.delegate placeDetailPanelDidSelectReservation];
    }
}

@end
