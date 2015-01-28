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
#import "UINavigationController+Additions.h"

#import "MRSLMenuViewController.h"
#import "MRSLProfileViewController.h"
#import "MRSLLandingViewController.h"
#import "MRSLWebBrowserViewController.h"

#import "MRSLUser.h"

static const CGFloat kOffscreenSwipeThreshold = 10.f;

@interface MRSLRootViewController ()
<MFMailComposeViewControllerDelegate,
UIGestureRecognizerDelegate,
MRSLMenuViewControllerDelegate>

@property (nonatomic, getter = isMenuOpen) BOOL menuOpen;
@property (nonatomic) BOOL shouldAllowMenuToOpen;
@property (nonatomic) BOOL shouldCheckForUser;
@property (nonatomic) BOOL keyboardOpen;

@property (nonatomic) CGFloat menuMaxX;

@property (weak, nonatomic) IBOutlet UIView *menuContainerView;
@property (weak, nonatomic) IBOutlet UIView *rootContainerView;

@property (weak, nonatomic) MRSLMenuViewController *menuViewController;

@property (nonatomic) CGPoint currentTouchPoint;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation MRSLRootViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldCheckForUser = YES;

    self.menuViewController = [self.childViewControllers lastObject];
    self.menuViewController.delegate = self;

    self.shouldAllowMenuToOpen = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableMenuOpen)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableMenuOpen)
                                                 name:MRSLModalWillDismissNotification
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
                                             selector:@selector(displayPlace:)
                                                 name:MRSLAppShouldDisplayPlaceNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayMorselDetail:)
                                                 name:MRSLAppShouldDisplayMorselDetailNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayProfessionalSettings:)
                                                 name:MRSLAppShouldDisplayProfessionalSettingsNotification
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
                                             selector:@selector(logUserOut)
                                                 name:MRSLServiceShouldLogOutUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayLanding)
                                                 name:MRSLAppShouldDisplayLandingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayFeedIfNothingVisible)
                                                 name:MRSLServiceDidLogInGuestNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toggleMenu)
                                                 name:MRSLAppShouldDisplayMenuBarNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayOnboarding)
                                                 name:MRSLAppShouldDisplayOnboardingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(userPanning:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.menuMaxX = MAX(270.f, [self.view getWidth] - 50.f);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_shouldCheckForUser) {
        self.shouldCheckForUser = NO;
        if (![MRSLUser currentUser]) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
    [self resumeTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self suspendTimer];
}

- (void)suspendTimer {
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
}

- (void)resumeTimer {
    [self suspendTimer];
    if (!_timer) {
        self.timer = [NSTimer timerWithTimeInterval:MRSLNotificationRefreshDelayDefault
                                             target:self
                                           selector:@selector(updateUnread)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer
                                     forMode:NSRunLoopCommonModes];
    }
}

- (void)updateUnread {
    [MRSLUser API_updateNotificationsAmount:nil
                                    failure:nil];
}

#pragma mark - Notification Methods

- (void)disableMenuOpen {
    self.shouldAllowMenuToOpen = NO;
}

- (void)enableMenuOpen {
    self.shouldAllowMenuToOpen = YES;
}

- (void)keyboardWillShow {
    self.keyboardOpen = YES;
}

- (void)keyboardWillHide {
    self.keyboardOpen = NO;
}

- (void)displayBaseViewController:(NSNotification *)notification {
    UINavigationController *baseNC = notification.object;
    MRSLBaseViewController *baseVC = (MRSLBaseViewController *)[[baseNC viewControllers] firstObject];
    [self presentBaseViewController:baseVC withContainingNavigationController:baseNC];
}

- (void)displayProfessionalSettings:(NSNotification *)notification {
    UINavigationController *professionalSettingsNC = [[UIStoryboard settingsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfessionalSettingsKey];
    MRSLBaseViewController *professionalSettingsVC = (MRSLBaseViewController *)[[professionalSettingsNC viewControllers] firstObject];
    if (notification.object) [professionalSettingsVC setupWithUserInfo:notification.object];
    [self presentBaseViewController:professionalSettingsVC withContainingNavigationController:professionalSettingsNC];
}

- (void)displayUserProfile:(NSNotification *)notification {
    UINavigationController *baseNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileKey];
    [self presentBaseViewControllerWithNotification:notification
                            andNavigationController:baseNC];
}

- (void)displayMorselDetail:(NSNotification *)notification {
    UINavigationController *baseNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailKey];
    [self presentBaseViewControllerWithNotification:notification
                            andNavigationController:baseNC];
}

- (void)displayPlace:(NSNotification *)notification {
    UINavigationController *baseNC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlaceKey];
    [self presentBaseViewControllerWithNotification:notification
                            andNavigationController:baseNC];
}

- (void)presentBaseViewControllerWithNotification:(NSNotification *)notification
                          andNavigationController:(UINavigationController *)navController {
    MRSLBaseViewController *baseVC = (MRSLBaseViewController *)[[navController viewControllers] firstObject];
    if (notification.object) [baseVC setupWithUserInfo:notification.object];
    [self presentBaseViewController:baseVC withContainingNavigationController:navController];
}

- (void)displayWebBrowser:(NSNotification *)notification {
    UINavigationController *webBrowserNC = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardWebBrowserKey];
    MRSLWebBrowserViewController *webBrowserVC = (MRSLWebBrowserViewController *)[[webBrowserNC viewControllers] firstObject];
    if (notification.object) {
        NSDictionary *webParams = notification.object;
        [webBrowserVC setTitle:webParams[@"title"]
                        andURL:webParams[@"url"]];
    }
    [self presentBaseViewController:webBrowserVC withContainingNavigationController:webBrowserNC];
}

- (void)displayEmailComposer:(NSNotification *)notification {
    if ([MFMailComposeViewController canSendMail]) {
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
    } else {
        [UIAlertView showOKAlertViewWithTitle:@"No Email Configured"
                                      message:[NSString stringWithFormat:@"Your device has no email accounts configured. Please set one up or send an email to %@ with your preferred client.", MORSEL_SUPPORT_EMAIL]];
    }
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

- (void)logUserOut {
    if (![UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    }
    [self dismissViewControllerAnimated:NO
                             completion:nil];
    [self displaySignUpAnimated:YES];
    [self resetChildNavigationControllers];
    [_appDelegate resetDataStore];
}

- (void)displayLanding {
    if (![UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    }
    UINavigationController *signUpNC = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardSignUpKey];
    MRSLLandingViewController *landingVC = [[signUpNC viewControllers] firstObject];
    landingVC.shouldDisplayDismiss = YES;
    [[self topPresentingViewController] presentViewController:signUpNC
                                                     animated:YES
                                                   completion:nil];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)displayFeedIfNothingVisible {
    if (![self containsChildNavigationController]) {
        [self menuViewControllerDidSelectMenuOption:MRSLMenuFeedKey];
    }
}

#pragma mark - Private Methods

- (void)displaySignUpAnimated:(BOOL)animated {
    UINavigationController *signUpNC = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardSignUpKey];
    [[self topPresentingViewController] presentViewController:signUpNC
                                                     animated:animated
                                                   completion:nil];
}

- (void)toggleMenu {
    if (!_shouldAllowMenuToOpen) return;
    if (_keyboardOpen) [self.view endEditing:YES];
    self.menuOpen = ([self.rootContainerView getX] > 0.f);
    [UIView animateWithDuration:.2f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.rootContainerView setX:(self.isMenuOpen ? 0.f : self.menuMaxX)];
                     } completion:nil];
    [self.rootContainerView setUserInteractionEnabled:self.isMenuOpen];
    [self enableScrollViewsInView:self.rootContainerView shouldEnable:self.isMenuOpen];
    self.menuOpen = !self.isMenuOpen;
}

- (void)displayOnboarding {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults boolForKey:@"didViewOnboarding"]) return;

    [standardUserDefaults setBool:YES
                           forKey:@"didViewOnboarding"];
    [standardUserDefaults synchronize];

    UIViewController *feedOnboardVC = [[UIStoryboard onboardingStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardOnboardingFeedKey];
    [feedOnboardVC.view setAccessibilityLabel:@"How to use"];
    [feedOnboardVC.view setFrame:CGRectMake(0.f, 0.f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [feedOnboardVC.view setAlpha:0.f];
    [feedOnboardVC willMoveToParentViewController:self];
    [self addChildViewController:feedOnboardVC];
    [self.view addSubview:feedOnboardVC.view];
    [UIView animateWithDefaultDurationAnimations:^{
        [feedOnboardVC.view setAlpha:1.f];
    }];
}

- (void)displayNavigationControllerEmbeddedViewControllerWithName:(NSString *)identifierName
                                            andStoryboardFileName:(NSString *)storyboardFileName {
    UIStoryboard *owningStoryboard = [UIStoryboard storyboardWithName:storyboardFileName
                                                               bundle:nil];
    UINavigationController *viewControllerNC = [owningStoryboard instantiateViewControllerWithIdentifier:identifierName];
    [self resetChildNavigationControllers];
    [self addChildViewController:viewControllerNC];
    [self.rootContainerView addSubview:viewControllerNC.view];
    [viewControllerNC didMoveToParentViewController:self];
}

- (void)enableScrollViewsInView:(UIView *)view shouldEnable:(BOOL)shouldEnable {
    if ([view respondsToSelector:@selector(setScrollEnabled:)]) {
        [(id)view setScrollEnabled:shouldEnable];
    }

    [[view subviews] enumerateObjectsUsingBlock:^(id subview, NSUInteger idx, BOOL *stop) {
        [self enableScrollViewsInView:subview shouldEnable:shouldEnable];
    }];
}

- (void)handlePanGestureBeganWithRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    [self.rootContainerView setUserInteractionEnabled:NO];
    [self enableScrollViewsInView:self.rootContainerView shouldEnable:NO];
}

- (void)handlePanGestureChangedWithRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    self.currentTouchPoint = [panGestureRecognizer locationInView:self.view];
    CGFloat panX = _currentTouchPoint.x;

    [self.rootContainerView setX:(panX > 0 && panX <= self.menuMaxX) ? panX : ((panX <= 0) ? 0 : self.menuMaxX)];
}

- (void)handlePanGestureEndedWithRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGFloat velocityX = [panGestureRecognizer velocityInView:self.view].x;
    BOOL shouldOpen = ([self.rootContainerView getX] / [self.view getWidth] > 0.5f) || velocityX > 800.f;
    if (velocityX < -800.f) shouldOpen = NO;

    self.menuOpen = shouldOpen;

    [UIView animateWithDuration:MIN([self.view getWidth] / velocityX, .2f)
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.rootContainerView setX:(shouldOpen ? self.menuMaxX : 0.f)];
                     } completion:^(BOOL finished) {
                         _currentTouchPoint = CGPointZero;
                         [self.rootContainerView setUserInteractionEnabled:!shouldOpen];
                         [self enableScrollViewsInView:self.rootContainerView shouldEnable:!shouldOpen];
                     }];
}


#pragma mark - MRSLMenuViewControllerDelegate

- (void)menuViewControllerDidSelectMenuOption:(NSString *)menuOption {
    if (self.isMenuOpen) [self toggleMenu];
    if (menuOption != nil && ![menuOption isEqualToString:MRSLMenuFeedKey] && ![menuOption isEqualToString:MRSLMenuExploreKey] && [MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    SWITCH(menuOption) {
        CASE(MRSLMenuAddKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"New morsel",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardMorselManageKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneMorselManagementKey];

            break;
        }
        CASE(MRSLMenuDraftsKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Drafts",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardMorselListKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneMorselManagementKey];
            break;
        }
        CASE(MRSLMenuFeedKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Feed",
                                                      @"_view": @"menu"}];
            if ([UIApplication sharedApplication].statusBarHidden) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                        withAnimation:UIStatusBarAnimationSlide];
            }
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardFeedKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneFeedKey];
            if (self.presentedViewController) {
                id presentedViewController = self.presentedViewController;
                [self dismissViewControllerAnimated:YES
                                         completion:^{
                                             /*
                                              This is essential due to UINavigationController instances originating from UIStoryboard
                                              not properly releasing contained view controllers.
                                              */
                                             if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
                                                 [(UINavigationController *)presentedViewController setViewControllers:nil];
                                             }
                                         }];
            }
            break;
        }
        CASE(MRSLMenuExploreKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Explore",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardExploreKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneExploreKey];
            break;
        }
        CASE(MRSLMenuNotificationsKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Notifications",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardNotificationsKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneActivityKey];
            break;
        }
        CASE(MRSLMenuActivityKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Activity",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardActivityKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneActivityKey];
            break;
        }
        CASE(MRSLMenuFindKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Find users",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardFindUsersKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneSocialKey];
            break;
        }
        CASE(MRSLMenuSettingsKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Settings",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardSettingsKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneSettingsKey];
            break;
        }
        CASE(MRSLMenuProfileKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"View profile",
                                                      @"_view": @"menu"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardProfileKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneProfileKey];
            break;
        }
        DEFAULT {
            break;
        }
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
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (void)userPanning:(UIPanGestureRecognizer *)panRecognizer {
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self handlePanGestureBeganWithRecognizer:panRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self handlePanGestureChangedWithRecognizer:panRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
            [self handlePanGestureEndedWithRecognizer:panRecognizer];
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return ([[[self.childViewControllers lastObject] viewControllers] count] == 1 ||
            [[self.childViewControllers lastObject] isDisplayingMorselAdd]);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //  Ignore the gesture when the menu is open since the User is most likely interacting w/ the Menu items
    if ((self.isMenuOpen && [touch locationInView:self.view].x < self.menuMaxX) || !_shouldAllowMenuToOpen) {
        return NO;
    } else {
        return [touch locationInView:self.rootContainerView].x < kOffscreenSwipeThreshold || self.isMenuOpen;
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
