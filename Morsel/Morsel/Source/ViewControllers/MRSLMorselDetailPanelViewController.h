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

@interface MRSLMorselDetailPanelViewController : UIViewController

@property (weak, nonatomic) id <MorselDetailPanelViewControllerDelegate> delegate;

@property (strong, nonatomic) MRSLMorsel *morsel;

- (void)addPanRecognizerSubscriber:(MRSLDetailHorizontalSwipePanelsViewController *)viewController;

@end
