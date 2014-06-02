//
//  MRSLPlaceDetailInfoCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceDetailInfoCollectionViewCell.h"

#import "MRSLPlaceInfo.h"

@interface MRSLPlaceDetailInfoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *headerInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation MRSLPlaceDetailInfoCollectionViewCell

- (void)setPlaceInfo:(MRSLPlaceInfo *)placeInfo {
    [super setPlaceInfo:placeInfo];
    [self setInfoHeader:placeInfo.primaryInfo
            andInfo:placeInfo.secondaryInfo];
}

- (void)setInfoHeader:(NSString *)header
              andInfo:(NSString *)info {
    self.headerInfoLabel.text = header;
    self.infoLabel.text = info;
}

@end
