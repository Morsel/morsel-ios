//
//  MRSLPlaceDetailContactCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceDetailContactCollectionViewCell.h"

#import "MRSLPlace.h"
#import "MRSLPlaceInfo.h"

@interface MRSLPlaceDetailContactCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *contactIconView;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;

@end

@implementation MRSLPlaceDetailContactCollectionViewCell

#pragma mark - Instance Methods

- (void)setPlaceInfo:(MRSLPlaceInfo *)placeInfo {
    [super setPlaceInfo:placeInfo];
    [self setContactInfo:placeInfo.secondaryInfo
            withIconType:placeInfo.primaryInfo];
}

- (void)setContactInfo:(NSString *)contact
          withIconType:(NSString *)iconType {
    self.contactLabel.text = contact;

    NSString *iconImageName = nil;

    if ([iconType isEqualToString:@"twitter"]) {
        iconImageName = @"icon-social-twitter-mark-dark";
    } else if ([iconType isEqualToString:@"phone"]) {
        iconImageName = @"icon-phone";
    } else if ([iconType isEqualToString:@"website"]) {
        iconImageName = @"icon-browser";
    }

    self.contactIconView.image = [UIImage imageNamed:iconImageName];
}

@end
