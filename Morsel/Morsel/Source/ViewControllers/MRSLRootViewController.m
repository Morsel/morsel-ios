//
//  MorselRootViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLRootViewController.h"

#import <MessageUI/MFMailComposeViewController.h>

#import "MRSLAPIService+Authentication.h"
#import "MRSLAPIService+Profile.h"

#import "MRSLFeedViewController.h"
#import "MRSLMorselAddViewController.h"
#import "MRSLProfileViewController.h"
#import "MRSLWebBrowserViewController.h"

#import "MRSLMenuBarView.h"

#import "MRSLUser.h"

@interface MRSLRootViewController ()
<MRSLMenuBarViewDelegate,
MFMailComposeViewControllerDelegate>

@property (nonatomic) BOOL shouldMenuBarOpen;
@property (nonatomic) BOOL shouldCheckForUser;

@property (nonatomic) UIStatusBarStyle currentStatusBarStyle;

@property (strong, nonatomic) NSMutableArray *navigationControllers;
@property (strong, nonatomic) UIViewController *currentViewController;

@property (weak, nonatomic) IBOutlet UIView *rootContainerView;

@property (weak, nonatomic) IBOutlet MRSLMenuBarView *menuBarView;

@end

@implementation MRSLRootViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldCheckForUser = YES;
    self.currentStatusBarStyle = UIStatusBarStyleDefault;

    [self.menuBarView setX:-[_menuBarView getWidth]];
    self.navigationControllers = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeToNewStatusBarStyle:)
                                                 name:MRSLAppDidRequestNewPreferredStatusBarStyle
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayFeed)
                                                 name:MRSLUserDidPublishMorselNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayMorselAdd:)
                                                 name:MRSLAppShouldDisplayMorselAddNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayBaseViewController:)
                                                 name:MRSLAppShouldDisplayBaseViewControllerNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayUserProfile:)
                                                 name:MRSLAppShouldDisplayUserProfileNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayWebBrowser:)
                                                 name:MRSLAppShouldDisplayWebBrowserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayEmailComposer:)
                                                 name:MRSLAppShouldDisplayEmailComposerNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callPhoneNumber:)
                                                 name:MRSLAppShouldCallPhoneNumberNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedIn:)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logUserOut)
                                                 name:MRSLServiceShouldLogOutUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMenuBar)
                                                 name:MRSLAppShouldDisplayMenuBarNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenuBar)
                                                 name:MRSLAppTouchPhaseDidBeginNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_shouldCheckForUser) {
        self.shouldCheckForUser = NO;

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
                                   @"username": NSNullIfNil(currentUser.username)}];
            [_appDelegate.apiService getUserProfile:currentUser
                                            success:^(id responseObject) {
                                                [_appDelegate.apiService getUserAuthenticationsWithSuccess:nil
                                                                                                   failure:nil];
                                            } failure:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                object:nil];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _currentStatusBarStyle;
}

#pragma mark - Notification Methods

- (void)changeToNewStatusBarStyle:(NSNotification *)notification {
    self.currentStatusBarStyle = [notification.object intValue];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)displayFeed {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Feed"
                                                  andStoryboardPrefix:@"Feed"];
}

- (void)displayMorselAdd:(NSNotification *)notification {
    UINavigationController *morselAddNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselAdd"];
    MRSLMorselAddViewController *morselAddVC = [[morselAddNC viewControllers] firstObject];
    if (notification.object) morselAddVC.skipToAddTitle = [notification.object boolValue];
    [self presentViewController:morselAddNC
                       animated:YES
                     completion:nil];
}

- (void)displayBaseViewController:(NSNotification *)notification {
    UINavigationController *baseNC = notification.object;
    MRSLBaseViewController *baseVC = (MRSLBaseViewController *)[[baseNC viewControllers] firstObject];
    [self presentBaseViewController:baseVC withContainingNavigationController:baseNC];
}

- (void)displayUserProfile:(NSNotification *)notification {
    UINavigationController *userProfileNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_Profile"];
    MRSLBaseViewController *profileVC = (MRSLBaseViewController *)[[userProfileNC viewControllers] firstObject];
    if (notification.object) [profileVC setupWithUserInfo:notification.object];
    [self presentBaseViewController:profileVC withContainingNavigationController:userProfileNC];
}

- (void)displayWebBrowser:(NSNotification *)notification {
    UINavigationController *webBrowserNC = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"sb_WebBrowser"];
    MRSLWebBrowserViewController *webBrowserVC = (MRSLWebBrowserViewController *)[[webBrowserNC viewControllers] firstObject];
    if (notification.object) {
        NSDictionary *webParams = notification.object;
        [webBrowserVC setTitle:webParams[@"title"]
                        andURL:webParams[@"url"]];
    }
    [self presentBaseViewController:webBrowserVC withContainingNavigationController:webBrowserNC];
}

- (void)displayEmailComposer:(NSNotification *)notification {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setMailComposeDelegate:self];
    [mailComposeViewController setToRecipients:@[ MORSEL_SUPPORT_EMAIL ]];
    if (notification.object) {
        [mailComposeViewController setTitle:notification.object[@"title"] ?: @""];
        [mailComposeViewController setSubject:notification.object[@"subject"] ?: @""];
        [mailComposeViewController setMessageBody:notification.object[@"body"] ?: @"" isHTML:YES];
    }

    [self presentViewController:mailComposeViewController
                       animated:YES
                     completion:nil];
}

- (void)callPhoneNumber:(NSNotification *)notification {
    if (notification.object) {
        NSMutableString *phoneString = [NSMutableString stringWithString:notification.object[@"phone"]];
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [phoneString stringCleanedForPhonePrompt]]];
        if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
            [[UIApplication sharedApplication] openURL:phoneURL];
        } else {
            [UIAlertView showAlertViewForErrorString:@"Calling not available on this device" delegate:nil];
        }
    }
}

- (void)presentBaseViewController:(MRSLBaseViewController *)baseViewController withContainingNavigationController:(UINavigationController *)navController {
    if (self.presentedViewController) {
        if ([self.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *presentedNavigationController = (UINavigationController *)self.presentedViewController;
            MRSLBaseViewController *currentBaseViewController = (MRSLBaseViewController *)[[presentedNavigationController viewControllers] firstObject];
            UIViewController *topPresentingViewController = [currentBaseViewController topPresentingViewController];
            if ([topPresentingViewController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)topPresentingViewController pushViewController:baseViewController
                                                                                 animated:YES];
            }
        }
    } else {
        [self presentViewController:navController
                           animated:YES
                         completion:nil];
    }
}

- (void)showMenuBar {
    self.shouldMenuBarOpen = YES;
    [self displayMenuBar];
}

- (void)hideMenuBar {
    if (_shouldMenuBarOpen) {
        self.shouldMenuBarOpen = NO;
        [self displayMenuBar];
    }
}

- (void)userLoggedIn:(NSNotification *)notification {
    [self syncDataAndPresentFeed];
}

- (void)logUserOut {
    if (![UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    }
    [self displaySignUpAnimated:YES];

    [_navigationControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
    }];
    [_navigationControllers removeAllObjects];
    [_menuBarView reset];
    [_appDelegate resetDataStore];
}

#pragma mark - Private Methods

- (UINavigationController *)getNavControllerWithClass:(Class)class {
    __block UINavigationController *foundNC = nil;

    [_navigationControllers enumerateObjectsUsingBlock:^(UINavigationController *navigationController, NSUInteger idx, BOOL *stop) {
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

- (void)syncDataAndPresentFeed {
    if ([UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
    }
    [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Feed"
                                                  andStoryboardPrefix:@"Feed"];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)displaySignUpAnimated:(BOOL)animated {
    UINavigationController *signUpNC = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:@"sb_SignUp"];

    [self presentViewController:signUpNC
                       animated:animated
                     completion:nil];
}

- (void)displayMenuBar {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_menuBarView setX:(_shouldMenuBarOpen) ? 0.f : -[_menuBarView getWidth]];
                     }];
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
    }

    if ([_currentViewController isEqual:viewControllerNC]) {
        UINavigationController *navController = (UINavigationController *)self.currentViewController;
        [navController popToRootViewControllerAnimated:YES];
    } else {
        [_currentViewController removeFromParentViewController];
        [_currentViewController.view removeFromSuperview];
        if (![[[(UINavigationController *)_currentViewController viewControllers] firstObject] isKindOfClass:[MRSLFeedViewController class]]) {
            [_navigationControllers removeObject:_currentViewController];
        }
        self.currentViewController = nil;

        [self addChildViewController:viewControllerNC];
        [self.rootContainerView addSubview:viewControllerNC.view];

        self.currentViewController = viewControllerNC;
    }
}

#pragma mark - MRSLMenuBarViewDelegate

- (void)menuBarDidSelectButtonOfType:(MRSLMenuBarButtonType)buttonType {
    switch (buttonType) {
        case MRSLMenuBarButtonTypeFeed:
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Bar Icon"
                                         properties:@{@"name": @"Feed"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Feed"
                                                          andStoryboardPrefix:@"Feed"];
            break;
        case MRSLMenuBarButtonTypeProfile:
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Bar Icon"
                                         properties:@{@"name": @"Profile"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Profile"
                                                          andStoryboardPrefix:@"Profile"];
            break;
        case MRSLMenuBarButtonTypeMyStuff:
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Bar Icon"
                                         properties:@{@"name": @"My Stuff"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"MyStuff"
                                                          andStoryboardPrefix:@"MyStuff"];
            break;
        case MRSLMenuBarButtonTypeActivity:
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Bar Icon"
                                         properties:@{@"name": @"Activity"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Activity"
                                                          andStoryboardPrefix:@"Activity"];
            break;
        case MRSLMenuBarButtonTypeFind:
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Bar Icon"
                                         properties:@{@"name": @"Find"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"FindFriends"
                                                          andStoryboardPrefix:@"Social"];
            break;
        case MRSLMenuBarButtonTypeSettings:
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Bar Icon"
                                         properties:@{@"name": @"Settings"}];
            [self displayNavigationControllerEmbeddedViewControllerWithPrefix:@"Settings"
                                                          andStoryboardPrefix:@"Settings"];
            break;
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            DDLogInfo(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            DDLogInfo(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            DDLogInfo(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            DDLogInfo(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            DDLogInfo(@"Mail not sent.");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
