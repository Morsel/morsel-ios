//
//  MorselFeedCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MorselFeedCollectionViewCell, MRSLMorsel, MRSLUser;

@protocol MorselFeedCollectionViewCellDelegate <NSObject>

@optional
- (void)morselPostCollectionViewCellDidDisplayProgression:(MorselFeedCollectionViewCell *)cell;
- (void)morselPostCollectionViewCellDidSelectProfileForUser:(MRSLUser *)user;
- (void)morselPostCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel;
- (void)morselPostCollectionViewCellDidSelectEditMorsel:(MRSLMorsel *)morsel;

@end

@interface MorselFeedCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<MorselFeedCollectionViewCellDelegate> delegate;

@property (nonatomic, weak) MRSLMorsel *morsel;

- (void)reset;

@end
