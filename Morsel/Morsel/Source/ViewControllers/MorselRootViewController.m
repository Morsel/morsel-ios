//
//  MorselRootViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselRootViewController.h"

#import "HomeViewController.h"
#import "MRSLSideBarViewController.h"
#import "ProfileViewController.h"

#import "MRSLUser.h"

@interface MorselRootViewController ()
<MRSLSideBarViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *navigationControllers;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, strong) MRSLSideBarViewController *sideBarViewController;

@property (weak, nonatomic) IBOutlet UIView *sideBarContainerView;
@property (weak, nonatomic) IBOutlet UIView *rootContainerView;

@end

@implementation MorselRootViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationControllers = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldDisplaySidebar:)
                                                 name:MRSLShouldDisplaySideBarNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedIn:)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];

    self.sideBarViewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"MRSLSideBarViewController"];
    _sideBarViewController.delegate = self;

    [self addChildViewController:_sideBarViewController];
    [self.sideBarContainerView addSubview:_sideBarViewController.view];

    MRSLUser *currentUser = [MRSLUser currentUser];

    if (!currentUser) {
        double delayInSeconds = 0.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self displaySignUpAnimated:NO];
        });
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                            object:nil];
    }
}

#pragma mark - Private Methods

- (void)shouldDisplaySidebar:(NSNotification *)notification {
    BOOL shouldDisplay = [notification.object boolValue];
    [self toggleSidebar:shouldDisplay];
}

- (void)toggleSidebar:(BOOL)shouldShow {
    [[UIApplication sharedApplication] setStatusBarHidden:shouldShow
                                            withAnimation:UIStatusBarAnimationFade];

    self.rootContainerView.userInteractionEnabled = !shouldShow;
    self.sideBarContainerView.userInteractionEnabled = shouldShow;

    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_rootContainerView setX:shouldShow ? self.view.frame.size.width - 40.f : 0.f];
    } completion:nil];
}

- (void)displaySignUpAnimated:(BOOL)animated {
    UINavigationController *signUpNC = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:@"SignUp"];

    [self presentViewController:signUpNC
                       animated:animated
                     completion:nil];
}

- (void)presentCreateMorsel {
    UINavigationController *createMorselNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"CreateMorsel"];

    [self presentViewController:createMorselNC
                       animated:YES
                     completion:nil];
}

- (void)displayHome {
    [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Home"];
}

- (void)displayProfile {
    [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Profile"];
}

- (void)displayNavigationControllerEmbeddedViewControllerWithPrefix:(NSString *)classPrefixName {
    if (_currentViewController) {
        [_currentViewController removeFromParentViewController];
        [_currentViewController.view removeFromSuperview];

        self.currentViewController = nil;
    }

    Class viewControllerClass = NSClassFromString([NSString stringWithFormat:@"%@ViewController", classPrefixName]);
    UINavigationController *viewControllerNC = [self getNavControllerWithClass:[viewControllerClass class]];

    if (!viewControllerNC) {
        UIStoryboard *owningStoryboard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@_iPhone", classPrefixName]
                                                                   bundle:nil];
        viewControllerNC = [owningStoryboard instantiateViewControllerWithIdentifier:classPrefixName];

        [self.navigationControllers addObject:viewControllerNC];

        [self addChildViewController:viewControllerNC];
        [self.rootContainerView addSubview:viewControllerNC.view];
    } else {
        [self addChildViewController:viewControllerNC];
        [self.rootContainerView addSubview:viewControllerNC.view];
    }

    [self addChildViewController:viewControllerNC];
    [self.rootContainerView addSubview:viewControllerNC.view];

    self.currentViewController = viewControllerNC;
}

- (UINavigationController *)getNavControllerWithClass:(Class)class {
    __block UINavigationController *foundNC = nil;

    [_navigationControllers enumerateObjectsUsingBlock:^(UINavigationController *navigationController, NSUInteger idx, BOOL *stop)
     {
         if ([navigationController isKindOfClass:[UINavigationController class]]) {
             if ([navigationController.viewControllers count] > 0) {
                 if ([[navigationController.viewControllers objectAtIndex:0] isKindOfClass:class]) {
                     foundNC = navigationController;
                     *stop = YES;
                 }
             }
         }
     }];

    return foundNC;
}

- (void)userLoggedIn:(NSNotification *)notification {
    [self syncDataAndPresentHome];
}

- (void)syncDataAndPresentHome {
    [self displayHome];

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)logUserOut {
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_rootContainerView setX:0.f];
    } completion:^(BOOL finished) {
        [_navigationControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
            [viewController removeFromParentViewController];
            [viewController.view removeFromSuperview];
        }];
        [_navigationControllers removeAllObjects];
        [Appdelegate resetDataStore];
    }];
    [self displaySignUpAnimated:YES];
}

#pragma mark - MRSLSideBarViewControllerDelegate

- (void)sideBarDidSelectMenuItemOfType:(SideBarMenuItemType)menuType {
    [self toggleSidebar:NO];

    switch (menuType) {
        case SideBarMenuItemTypeHome:
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Home"];
            break;
        case SideBarMenuItemTypeProfile:
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Profile"];
            break;
        case SideBarMenuItemTypeDrafts:
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Drafts"];
            break;
        case SideBarMenuItemTypeLogout:
            [self logUserOut];
            break;
        default:
            break;
    }
}

@end
