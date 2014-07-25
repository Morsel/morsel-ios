//
//  MRSLFeedPanelCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLFeedPanelViewController;

@protocol MRSLFeedPanelCollectionViewCellDelegate <NSObject>

@optional
- (void)feedPanelCollectionViewCellDidSelectPreviousMorsel;
- (void)feedPanelCollectionViewCellDidSelectNextMorsel;

@end

@interface MRSLFeedPanelCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MRSLFeedPanelCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLFeedPanelViewController *feedPanelViewController;

- (void)setOwningViewController:(UIViewController *)owningViewController
                       withMorsel:(MRSLMorsel *)morsel;

@end
