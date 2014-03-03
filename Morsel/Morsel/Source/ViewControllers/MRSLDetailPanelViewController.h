//
//  MorselDetailPanelViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLDetailHorizontalSwipePanelsViewController, MRSLUser;

@protocol MorselDetailPanelViewControllerDelegate <NSObject>

@optional
- (void)morselDetailPanelViewDidSelectAddComment;
- (void)morselDetailPanelViewDidSelectUser:(MRSLUser *)user;
- (void)morselDetailPanelViewScrollOffsetChanged:(CGFloat)offset;

@end

@class MRSLMorsel;

@interface MRSLDetailPanelViewController : UIViewController

@property (nonatomic, weak) id <MorselDetailPanelViewControllerDelegate> delegate;

@property (nonatomic, strong) MRSLMorsel *morsel;

- (void)addPanRecognizerSubscriber:(MRSLDetailHorizontalSwipePanelsViewController *)viewController;

@end
