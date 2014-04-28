//
//  MRSLUserFollowListViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLUserFollowListViewController : MRSLBaseViewController

@property (weak, nonatomic) MRSLUser *user;

@property (nonatomic) BOOL shouldDisplayFollowing;

@end
