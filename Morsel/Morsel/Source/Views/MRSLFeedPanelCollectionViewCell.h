//
//  MRSLFeedPanelCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLFeedPanelCollectionViewCellDelegate <NSObject>

@optional
- (void)feedPanelCollectionViewCellDidSelectPreviousMorsel;
- (void)feedPanelCollectionViewCellDidSelectNextMorsel;

@end

@interface MRSLFeedPanelCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MRSLFeedPanelCollectionViewCellDelegate> delegate;

- (void)setOwningViewController:(UIViewController *)owningViewController
                       withMorsel:(MRSLMorsel *)morsel;

@end
