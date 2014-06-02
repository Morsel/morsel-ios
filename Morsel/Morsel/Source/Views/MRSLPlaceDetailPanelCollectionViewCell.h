//
//  MRSLPlaceDetailPanelCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLPlaceDetailPanelCollectionViewCellDelegate <NSObject>

@optional
- (void)placeDetailPanelDidSelectMenu;
- (void)placeDetailPanelDidSelectReservation;

@end

@interface MRSLPlaceDetailPanelCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MRSLPlaceDetailPanelCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLPlace *place;

@end
