//
//  MRSLBaseViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLBaseViewController : UIViewController

- (void)setupNavigationItems;

- (IBAction)dismiss;
- (IBAction)displayMenuBar;
- (IBAction)displayMorselAdd;
- (IBAction)displayAddPlace:(id)sender;
- (IBAction)displayMorselShare;
- (IBAction)displayProfessionalSettings;
- (IBAction)goBack;

- (void)changeStatusBarStyle:(UIStatusBarStyle)style;
- (void)setupWithUserInfo:(NSDictionary *)userInfo;

- (UIViewController *)topPresentingViewController;

@end
