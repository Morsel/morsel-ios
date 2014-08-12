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
#import "MRSLMenuBarButtonItem.h"

#import "MRSLUser.h"

@implementation MRSLBaseViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"root";
}

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
        backButton.accessibilityLabel = @"Back";
        [self.navigationItem setLeftBarButtonItem:backButton];
    } else if (([self.navigationController.viewControllers count] == 1 && !self.presentingViewController) || [self.navigationController isDisplayingMorselAdd]) {
        if (!self.navigationController.navigationBarHidden) {
            MRSLMenuBarButtonItem *menuBarButtonItem = [MRSLMenuBarButtonItem menuBarButtonItem];
            [(UIButton *)menuBarButtonItem.customView addTarget:self
                                                         action:@selector(displayMenuBar)
                                               forControlEvents:UIControlEventTouchUpInside];
            [self.navigationItem setLeftBarButtonItem:menuBarButtonItem];
        }
    } else if (self.presentingViewController && [self.navigationController.viewControllers count] == 1) {
        if (self.navigationController) {
            UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-collapse"]
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(dismiss)];
            menuButton.accessibilityLabel = @"Dismiss";
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
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Menu",
                                              @"_view": self.mp_eventView ?: @"menu"}];
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMenuBarNotification
                                                        object:nil];
}

- (IBAction)displayMorselAdd {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Add morsel",
                                              @"_view": self.mp_eventView ?: @"menu"}];
    MRSLMorselAddTitleViewController *morselAddTitleVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselAddTitleViewControllerKey];
    [self.navigationController pushViewController:morselAddTitleVC
                                         animated:YES];
}

- (IBAction)displayAddPlace:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Add place",
                                              @"_view": self.mp_eventView ?: @"menu"}];
    [self.navigationController pushViewController:[[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlacesAddViewControllerKey]
                                         animated:YES];
}

- (IBAction)displayMorselShare {
    // Should be overridden
}

- (IBAction)displayProfessionalSettings {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Professional settings",
                                              @"_view": self.mp_eventView ?: @"menu"}];
    [self.navigationController pushViewController:[[UIStoryboard settingsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfessionalSettingsTableViewControllerKey]
                                         animated:YES];
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)report {
    // Should be overridden if intended to be used
}

#pragma mark - Routing Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    @throw @"setupWithUserInfo Not Implemented in subclass!";
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
