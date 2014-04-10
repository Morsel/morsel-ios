//
//  MorselFeedCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLFeedCollectionViewCell, MRSLItem, MRSLUser;

@protocol MorselFeedCollectionViewCellDelegate <NSObject>

@optional
- (void)itemMorselCollectionViewCellDidDisplayProgression:(MRSLFeedCollectionViewCell *)cell;
- (void)itemMorselCollectionViewCellDidSelectProfileForUser:(MRSLUser *)user;
- (void)itemMorselCollectionViewCellDidSelectMorsel:(MRSLItem *)item;
- (void)itemMorselCollectionViewCellDidSelectEditMorsel:(MRSLItem *)item;

@end

@interface MRSLFeedCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<MorselFeedCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLItem *item;

- (void)reset;

@end
