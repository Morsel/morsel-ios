//
//  UIViewController+Base.m
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIViewController+Base.h"

#import "MRSLMenuBarButtonItem.h"

#import "MRSLUser.h"

@implementation UIViewController (Base)

- (void)setupNavigationItems {
    if ([self.navigationController.viewControllers count] > 1) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(goBack)];
        [self.navigationItem setLeftBarButtonItem:backButton];
    } else if ([self.navigationController.viewControllers count] == 1 && !self.presentingViewController) {
        if (!self.navigationController.navigationBarHidden) {
            MRSLMenuBarButtonItem *menuBarButtonItem = [MRSLMenuBarButtonItem menuBarButtonItem];
            [(UIButton *)menuBarButtonItem.customView addTarget:self
                                                         action:@selector(displayMenuBar)
                                               forControlEvents:UIControlEventTouchUpInside];
            [self.navigationItem setLeftBarButtonItem:menuBarButtonItem];
            if ([[MRSLUser currentUser] isProfessional]) {
                UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(displayMorselAdd)];
                [self.navigationItem setRightBarButtonItem:addButton];
            }
        }
    } else if (self.presentingViewController && [self.navigationController.viewControllers count] == 1) {
        if (self.navigationController) {
            UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-collapse"]
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(dismiss)];
            [self.navigationItem setLeftBarButtonItem:menuButton];
        }
    }
}

#pragma mark - Action Methods

- (IBAction)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)displayMenuBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMenuBarNotification
                                                        object:nil];
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Routing Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    @throw @"setupWithUserInfo Not Implemented in subclass!";
}

#pragma mark - Utility Methods

- (UIViewController *)topPresentingViewController {
    UIViewController *topMostVC = (self.navigationController) ? self.navigationController : self;
    UIViewController *potentialTopMostVC = topMostVC;
    while (potentialTopMostVC != nil) {
        topMostVC = potentialTopMostVC;
        if (potentialTopMostVC.navigationController) potentialTopMostVC = potentialTopMostVC.navigationController;
        potentialTopMostVC = potentialTopMostVC.presentedViewController;
    }
    return topMostVC;
}

@end
