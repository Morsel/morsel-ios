//
//  MRSLBaseViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

#import "MRSLUser.h"

@implementation MRSLBaseViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationItems];
}

- (void)setupNavigationItems {
    if ([self.navigationController.viewControllers count] > 1) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(goBack)];
        [self.navigationItem setLeftBarButtonItem:backButton];
    } else if ([self.navigationController.viewControllers count] == 1 && !self.presentingViewController) {
        if (!self.navigationController.navigationBarHidden) {
            UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-menubar-red"]
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(displayMenuBar)];
            [self.navigationItem setLeftBarButtonItem:menuButton];
        }
    } else if (self.presentingViewController && [self.navigationController.viewControllers count] == 1) {
        if (self.navigationController) {
            UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-dismiss"]
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

- (IBAction)displayMorselAdd {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMorselAddNotification
                                                        object:nil];
}

- (IBAction)displayMorselShare {
    // Should be overridden
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Routing Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    @throw @"setupWithUserInfo Not Implemented in subclass!";
}

#pragma mark - Appearance Methods

- (void)changeStatusBarStyle:(UIStatusBarStyle)style {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppDidRequestNewPreferredStatusBarStyle
                                                        object:@(style)];
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

- (void)reset {
    if (self.navigationItem) {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self reset];
}

@end
