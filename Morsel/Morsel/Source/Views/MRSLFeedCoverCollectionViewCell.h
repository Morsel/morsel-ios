//
//  MRSLFeedCoverCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLFeedCoverCollectionViewCellDelegate <NSObject>

@optional
- (void)feedCoverCollectionViewCellDidSelectMorsel:(MRSLItem *)item;

@end

@interface MRSLFeedCoverCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MRSLFeedCoverCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLMorsel *morsel;

@end
