//
//  MRSLPlaceDetailHoursCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceDetailHoursCollectionViewCell.h"

#import "MRSLPlaceInfo.h"

@interface MRSLPlaceDetailHoursCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dayRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourRangeLabel;

@end

@implementation MRSLPlaceDetailHoursCollectionViewCell

#pragma mark - Instance Methods

- (void)setPlaceInfo:(MRSLPlaceInfo *)placeInfo {
    [super setPlaceInfo:placeInfo];
    [self setDaysOpen:placeInfo.primaryInfo
            andHours:placeInfo.secondaryInfo];
}

- (void)setDaysOpen:(NSString *)daysOpen
           andHours:(NSString *)hours {
    self.dayRangeLabel.text = daysOpen;
    self.hourRangeLabel.text = hours;
}

@end
