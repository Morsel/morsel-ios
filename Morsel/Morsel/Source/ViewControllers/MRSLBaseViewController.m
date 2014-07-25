//
//  MRSLBaseViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

#import "UINavigationController+Additions.h"

#import "MRSLMorselAddTitleViewController.h"

#import "MRSLUser.h"

@implementation MRSLBaseViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor morselDefaultBackgroundColor]];
    [self setupNavigationItems];
}

- (void)setupNavigationItems {
    if ([self.navigationController.viewControllers count] > 1 && ![self.navigationController isDisplayingMorselAdd]) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(goBack)];
        [self.navigationItem setLeftBarButtonItem:backButton];
    } else if (([self.navigationController.viewControllers count] == 1 && !self.presentingViewController) || [self.navigationController isDisplayingMorselAdd]) {
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
    UINavigationController *containingNavigationController = self.navigationController;
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          /*
                                                           This is essential due to UINavigationController instances originating from UIStoryboard
                                                           not properly releasing contained view controllers.
                                                           */
                                                          if (containingNavigationController) {
                                                              [containingNavigationController setViewControllers:nil];
                                                          }
                                                      }];
}

- (IBAction)displayMenuBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMenuBarNotification
                                                        object:nil];
}

- (IBAction)displayMorselAdd {
    MRSLMorselAddTitleViewController *morselAddTitleVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselAddTitleViewControllerKey];
    [self.navigationController pushViewController:morselAddTitleVC
                                         animated:YES];
}

- (IBAction)displayAddPlace:(id)sender {
    [self.navigationController pushViewController:[[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlacesAddViewControllerKey]
                                         animated:YES];
}

- (IBAction)displayMorselShare {
    // Should be overridden
}

- (IBAction)displayProfessionalSettings {
    [self.navigationController pushViewController:[[UIStoryboard settingsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfessionalSettingsTableViewControllerKey]
                                         animated:YES];
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

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UINavigationController *containingNavigationController = (self.presentedViewController) ? self.presentedViewController.navigationController : self.navigationController;
    [super dismissViewControllerAnimated:flag completion:^{
        /*
         This is essential due to UINavigationController instances originating from UIStoryboard
         not properly releasing contained view controllers.
         */
        if (containingNavigationController) {
            [containingNavigationController setViewControllers:nil];
        }
        if (completion) completion();
    }];
}

- (void)reset {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self resetChildViewControllers];
    if (self.navigationItem) {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [self reset];
}

@end
