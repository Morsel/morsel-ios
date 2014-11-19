//
//  MRSLFeedCoverCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLFeedCoverCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) MRSLMorsel *morsel;

@property (nonatomic, getter = isHomeFeedItem) BOOL homeFeedItem;

@end
