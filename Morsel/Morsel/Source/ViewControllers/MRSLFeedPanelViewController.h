//
//  MRSLFeedPanelCollectionViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLFeedPanelViewControllerDelegate <NSObject>

@optional
- (void)feedPanelViewControllerDidSelectPreviousStory;
- (void)feedPanelViewControllerDidSelectNextStory;

@end

@interface MRSLFeedPanelViewController : UIViewController

@property (weak, nonatomic) id <MRSLFeedPanelViewControllerDelegate> delegate;

@property (weak, nonatomic) MRSLPost *post;

@end