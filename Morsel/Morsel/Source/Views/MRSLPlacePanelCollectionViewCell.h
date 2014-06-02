//
//  MRSLPlacePanelCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLPlacePanelCollectionViewCellDelegate <NSObject>

@optional
- (void)placePanelDidSelectDetails;

@end

@interface MRSLPlacePanelCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MRSLPlacePanelCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLPlace *place;

@end
