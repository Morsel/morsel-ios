//
//  MRSLBaseViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

@implementation MRSLBaseViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.navigationController.viewControllers count] > 1 && !self.presentingViewController) {
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

            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-add-red"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(displayStoryAdd)];
            [self.navigationItem setRightBarButtonItem:addButton];
        }
    } else if (self.presentingViewController) {
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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)displayMenuBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMenuBarNotification
                                                        object:nil];
}

- (IBAction)displayStoryAdd {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayStoryAddNotification
                                                        object:nil];
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Appearance Methods

- (void)changeStatusBarStyle:(UIStatusBarStyle)style {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppDidRequestNewPreferredStatusBarStyle object:@(style)];
}

@end
