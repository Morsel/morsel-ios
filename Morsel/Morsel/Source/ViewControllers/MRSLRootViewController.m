//
//  MorselRootViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLRootViewController.h"

#import "MRSLStoryAddViewController.h"

#import "MRSLTabBarView.h"

#import "MRSLUser.h"

@interface MRSLRootViewController ()
<MRSLTabBarViewDelegate>

@property (strong, nonatomic) NSMutableArray *navigationControllers;
@property (strong, nonatomic) UIViewController *currentViewController;

@property (weak, nonatomic) IBOutlet UIView *rootContainerView;

@property (weak, nonatomic) IBOutlet MRSLTabBarView *tabBarView;

@end

@implementation MRSLRootViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationControllers = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedIn:)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logUserOut)
                                                 name:MRSLServiceShouldLogOutUserNotification
                                               object:nil];

    MRSLUser *currentUser = [MRSLUser currentUser];

    if (!currentUser) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        double delayInSeconds = 0.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self displaySignUpAnimated:NO];
        });
    } else {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:[NSString stringWithFormat:@"%i", currentUser.userIDValue]];
        [mixpanel.people set:@{@"first_name": NSNullIfNil(currentUser.first_name),
                               @"last_name": NSNullIfNil(currentUser.last_name),
                               @"created_at": NSNullIfNil(currentUser.creationDate),
                               @"title": NSNullIfNil(currentUser.title),
                               @"username": NSNullIfNil(currentUser.username)}];
        [_appDelegate.morselApiService getUserProfile:currentUser
                                              success:nil
                                              failure:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                            object:nil];
    }
}

#pragma mark - Private Methods

- (void)displaySignUpAnimated:(BOOL)animated {
    UINavigationController *signUpNC = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:@"sb_SignUp"];

    [self presentViewController:signUpNC
                       animated:animated
                     completion:nil];
}

- (void)displayHome {
    [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Home"
                                                  andStoryboardPrefix:@"Home"];
}

- (void)displayNavigationControllerEmbeddedViewControllerWithPrefix:(NSString *)classPrefixName
                                                andStoryboardPrefix:(NSString *)storyboardPrefixName {
    Class viewControllerClass = NSClassFromString([NSString stringWithFormat:@"MRSL%@ViewController", classPrefixName]);
    UINavigationController *viewControllerNC = [self getNavControllerWithClass:[viewControllerClass class]];

    if (!viewControllerNC) {
        UIStoryboard *owningStoryboard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@_iPhone", storyboardPrefixName]
                                                                   bundle:nil];
        viewControllerNC = [owningStoryboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@_%@", @"sb", classPrefixName]];

        [self.navigationControllers addObject:viewControllerNC];
    } else {
        if (self.currentViewController != viewControllerNC) {
            UINavigationController *navController = (UINavigationController *)viewControllerNC;
            if ([[navController.viewControllers firstObject] isKindOfClass:[MRSLStoryAddViewController class]]) {
                [navController popToRootViewControllerAnimated:NO];
            }
        }
    }

    if ([_currentViewController isEqual:viewControllerNC]) {
        UINavigationController *navController = (UINavigationController *)self.currentViewController;
        [navController popToRootViewControllerAnimated:YES];
    } else {
        [_currentViewController removeFromParentViewController];
        [_currentViewController.view removeFromSuperview];

        self.currentViewController = nil;

        [self addChildViewController:viewControllerNC];
        [self.rootContainerView addSubview:viewControllerNC.view];

        self.currentViewController = viewControllerNC;
    }
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
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
    }

    [self displayHome];

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)logUserOut {
    [self displaySignUpAnimated:YES];
    
    [_navigationControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
    }];
    [_navigationControllers removeAllObjects];
    [_tabBarView reset];
    [_appDelegate resetDataStore];
}

#pragma mark - MRSLTabBarViewDelegate

- (void)tabBarDidSelectButtonOfType:(MRSLTabBarButtonType)buttonType {
    switch (buttonType) {
        case MRSLTabBarButtonTypeHome:
            [[MRSLEventManager sharedManager] track:@"Tapped View Home"
                                         properties:@{@"view": @"MRSLRootViewController"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Home"
                                                          andStoryboardPrefix:@"Home"];
            break;
        case MRSLTabBarButtonTypeActivity:
            [[MRSLEventManager sharedManager] track:@"Tapped View Activity"
                                         properties:@{@"view": @"MRSLRootViewController"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Activity"
                                                          andStoryboardPrefix:@"Activity"];
            break;
        case MRSLTabBarButtonTypeAdd:
            [[MRSLEventManager sharedManager] track:@"Tapped View Add Story"
                                         properties:@{@"view": @"MRSLRootViewController"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"StoryAdd"
                                                          andStoryboardPrefix:@"StoryManagement"];
            break;
        case MRSLTabBarButtonTypeMyStuff:
            [[MRSLEventManager sharedManager] track:@"Tapped View My Stuff"
                                         properties:@{@"view": @"MRSLRootViewController"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"MyStuff"
                                                          andStoryboardPrefix:@"MyStuff"];
            break;
        case MRSLTabBarButtonTypeMore:
            [[MRSLEventManager sharedManager] track:@"Tapped View More"
                                         properties:@{@"view": @"MRSLRootViewController"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"More"
                                                          andStoryboardPrefix:@"More"];
            break;
        default:
            break;
    }
}

@end