//
//  MorselPostCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMorsel, MRSLUser;

@protocol MorselPostCollectionViewCellDelegate <NSObject>

@optional
- (void)morselPostCollectionViewCellDidSelectProfileForUser:(MRSLUser *)user;
- (void)morselPostCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel;

@end

@interface MorselPostCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <MorselPostCollectionViewCellDelegate> delegate;

@property (nonatomic, weak) MRSLMorsel *morsel;

- (void)reset;

@end
