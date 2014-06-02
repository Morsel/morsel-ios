//
//  MRSLPlacePanelCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlacePanelCollectionViewCell.h"

#import <MapKit/MapKit.h>

#import "MRSLPlace.h"

@interface MRSLPlacePanelCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet MKMapView *placeMapView;

@end

@implementation MRSLPlacePanelCollectionViewCell

- (void)setPlace:(MRSLPlace *)place {
    if (_place != place) {
        _place = place;
        self.nameLabel.text = _place.name;
        self.addressLabel.text = [_place fullAddress];

        if (_place.lat && _place.lon) {
            CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(_place.latValue, _place.lonValue);
            MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(locationCoordinate, MKCoordinateSpanMake(.002f, .002f));
            [self.placeMapView setRegion:coordinateRegion];
        } else {
            self.placeMapView.hidden = YES;
        }
    }
}

#pragma mark - Action Methods

- (IBAction)displayDetails {
    if ([self.delegate respondsToSelector:@selector(placePanelDidSelectDetails)]) {
        [self.delegate placePanelDidSelectDetails];
    }
}

@end
