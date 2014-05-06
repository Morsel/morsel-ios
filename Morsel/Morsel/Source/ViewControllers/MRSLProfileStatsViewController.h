//
//  MRSLProfileStatsViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLProfileStatsViewControllerDelegate <NSObject>

@optional
- (void)profileStatsViewControllerDidSelectLiked;
- (void)profileStatsViewControllerDidSelectFollowers;
- (void)profileStatsViewControllerDidSelectFollowing;

@end

@interface MRSLProfileStatsViewController : UIViewController

@property (weak, nonatomic) id <MRSLProfileStatsViewControllerDelegate> delegate;

@property (weak, nonatomic) MRSLUser *user;

@end
