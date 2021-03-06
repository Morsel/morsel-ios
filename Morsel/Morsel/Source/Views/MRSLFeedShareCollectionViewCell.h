//
//  MRSLFeedShareCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 4/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLFeedShareCollectionViewCellDelegate <NSObject>

@optional
- (void)feedShareCollectionViewCellDidSelectNextMorsel;

@end

@interface MRSLFeedShareCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MRSLFeedShareCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLMorsel *morsel;
@property (weak, nonatomic) MRSLMorsel *nextMorsel;

@end
