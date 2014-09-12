//
//  MRSLBaseViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

#import "UINavigationController+Additions.h"

#import "MRSLTemplateSelectionViewController.h"
#import "MRSLMenuBarButtonItem.h"

#import "MRSLUser.h"

@interface MRSLBaseViewController ()

@property (strong, nonatomic) UIBarButtonItem *storedLeftItem;
@property (strong, nonatomic) UIBarButtonItem *storedRightItem;

@end

@implementation MRSLBaseViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"root";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(modalWillDisplay:)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(modalWillDismiss:)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
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
    } else if (([self.navigationController.viewControllers count] == 1 && !self.presentingViewController) || ([self.navigationController isDisplayingMorselAdd] && !self.presentingViewController)) {
        if (!self.navigationController.navigationBarHidden) {
            MRSLMenuBarButtonItem *menuBarButtonItem = [MRSLMenuBarButtonItem menuBarButtonItem];
            [(UIButton *)menuBarButtonItem.customView addTarget:self
                                                         action:@selector(displayMenuBar)
                                               forControlEvents:UIControlEventTouchUpInside];
            [self.navigationItem setLeftBarButtonItem:menuBarButtonItem];
        }
    } else if (self.presentingViewController && [self.navigationController.viewControllers count] == 1) {
        if (self.navigationController) {
            UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-collapse"]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(dismiss)];
            dismissButton.accessibilityLabel = @"Dismiss";
            [self.navigationItem setLeftBarButtonItem:dismissButton];
        }
    }
}

#pragma mark - Notification Methods

- (void)modalWillDisplay:(NSNotification *)notification {
    self.storedLeftItem = self.navigationItem.leftBarButtonItem;
    self.storedRightItem = self.navigationItem.rightBarButtonItem;

    /*
     Ignoring warning because the dismiss: selector does exist within the notification.object
     */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:notification.object
                                                                   action:@selector(dismiss:)];
#pragma clang diagnostic pop
    closeButton.accessibilityLabel = @"Close";

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-transparent"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:nil];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setRightBarButtonItem:closeButton];
}

- (void)modalWillDismiss:(NSNotification *)notification {
    [self.navigationItem setLeftBarButtonItem:_storedLeftItem];
    [self.navigationItem setRightBarButtonItem:_storedRightItem];
    self.storedLeftItem = nil;
    self.storedRightItem = nil;
}

#pragma mark - Action Methods

- (IBAction)dismissModal {

}

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
                                 properties:@{@"_title": @"New morsel",
                                              @"_view": self.mp_eventView ?: @"menu"}];
    MRSLTemplateSelectionViewController *templateSelectionVC = [[UIStoryboard templatesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardTemplateSelectionViewControllerKey];
    [self.navigationController pushViewController:templateSelectionVC
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
    self.storedLeftItem = nil;
    self.storedRightItem = nil;
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
