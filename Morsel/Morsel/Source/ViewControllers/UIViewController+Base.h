//
//  UIViewController+Base.h
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Base)

- (void)setupNavigationItems;

- (IBAction)dismiss;
- (IBAction)displayMenuBar;
- (IBAction)displayMorselAdd;
- (IBAction)goBack;

- (void)changeStatusBarStyle:(UIStatusBarStyle)style;
- (void)setupWithUserInfo:(NSDictionary *)userInfo;

- (UIViewController *)topPresentingViewController;

@end
