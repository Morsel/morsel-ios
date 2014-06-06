//
//  MRSLBaseViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLBaseViewController : UIViewController

@property (nonatomic) BOOL isFeed;

- (IBAction)dismiss;
- (IBAction)displayMenuBar;
- (IBAction)displayMorselAdd;
- (IBAction)displayMorselShare;
- (IBAction)goBack;

- (void)changeStatusBarStyle:(UIStatusBarStyle)style;
- (void)setupWithUserInfo:(NSDictionary *)userInfo;

- (UIViewController *)topPresentingViewController;

@end
