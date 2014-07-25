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
#import "MRSLWebBrowserViewController.h"

#import "MRSLUser.h"

static const CGFloat kOffscreenSwipeThreshold = 10.f;
static const CGFloat MRSLMenuViewWidth = 270.f;

@interface MRSLRootViewController ()
<MFMailComposeViewControllerDelegate,
UIGestureRecognizerDelegate,
MRSLMenuViewControllerDelegate>

@property (nonatomic, getter = isMenuOpen) BOOL menuOpen;
@property (nonatomic) BOOL shouldAllowMenuToOpen;
@property (nonatomic) BOOL shouldCheckForUser;
@property (nonatomic) BOOL keyboardOpen;

@property (nonatomic) UIStatusBarStyle currentStatusBarStyle;

@property (weak, nonatomic) IBOutlet UIView *menuContainerView;
@property (weak, nonatomic) IBOutlet UIView *rootContainerView;

@property (weak, nonatomic) MRSLMenuViewController *menuViewController;

@property (nonatomic) CGPoint currentTouchPoint;

@end

@implementation MRSLRootViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldCheckForUser = YES;
    self.currentStatusBarStyle = UIStatusBarStyleDefault;

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
                                             selector:@selector(changeToNewStatusBarStyle:)
                                                 name:MRSLAppDidRequestNewPreferredStatusBarStyle
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
                                             selector:@selector(toggleMenu)
                                                 name:MRSLAppShouldDisplayMenuBarNotification
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
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _currentStatusBarStyle;
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

- (void)changeToNewStatusBarStyle:(NSNotification *)notification {
    self.currentStatusBarStyle = [notification.object intValue];
    [self setNeedsStatusBarAppearanceUpdate];
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
    UINavigationController *userProfileNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileKey];
    MRSLBaseViewController *profileVC = (MRSLBaseViewController *)[[userProfileNC viewControllers] firstObject];
    if (notification.object) [profileVC setupWithUserInfo:notification.object];
    [self presentBaseViewController:profileVC withContainingNavigationController:userProfileNC];
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

#pragma mark - Private Methods

- (void)displaySignUpAnimated:(BOOL)animated {
    UINavigationController *signUpNC = [[UIStoryboard loginStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardSignUpKey];
    [self presentViewController:signUpNC
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
                         [self.rootContainerView setTransform:CGAffineTransformMakeTranslation((self.isMenuOpen ? 0.f : MRSLMenuViewWidth), 0.0f)];
                     } completion:nil];
    [self.rootContainerView setUserInteractionEnabled:self.isMenuOpen];
    [self enableScrollViewsInView:self.rootContainerView shouldEnable:self.isMenuOpen];
    self.menuOpen = !self.isMenuOpen;
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

    [self.rootContainerView setTransform:CGAffineTransformMakeTranslation((panX > 0 && panX <= MRSLMenuViewWidth) ? panX : ((panX <= 0) ? 0 : MRSLMenuViewWidth), 0.0f)];
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
                         [self.rootContainerView setTransform:CGAffineTransformMakeTranslation((shouldOpen ? MRSLMenuViewWidth : 0.f), 0.0f)];
                     } completion:^(BOOL finished) {
                         _currentTouchPoint = CGPointZero;
                         [self.rootContainerView setUserInteractionEnabled:!shouldOpen];
                         [self enableScrollViewsInView:self.rootContainerView shouldEnable:!shouldOpen];
                     }];
}


#pragma mark - MRSLMenuViewControllerDelegate

- (void)menuViewControllerDidSelectMenuOption:(NSString *)menuOption {
    if (self.isMenuOpen) [self toggleMenu];
    SWITCH(menuOption) {
        CASE(MRSLMenuAddKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Morsel Add"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardMorselAddKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneMorselManagementKey];
            break;
        }
        CASE(MRSLMenuDraftsKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Drafts"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardMorselListKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneMorselManagementKey];
            break;
        }
        CASE(MRSLMenuFeedKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Feed"}];
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
        CASE(MRSLMenuNotificationsKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Activity"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardActivityKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneActivityKey];
            break;
        }
        CASE(MRSLMenuPlacesKey) {
            break;
        }
        CASE(MRSLMenuPeopleKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Following People"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardFollowingPeopleKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneProfileKey];
            break;
        }
        CASE(MRSLMenuFindKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Find"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardFindFriendsKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneSocialKey];
            break;
        }
        CASE(MRSLMenuSettingsKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Settings"}];
            [self displayNavigationControllerEmbeddedViewControllerWithName:MRSLStoryboardSettingsKey
                                                      andStoryboardFileName:MRSLStoryboardiPhoneSettingsKey];
            break;
        }
        CASE(MRSLMenuProfileKey) {
            [[MRSLEventManager sharedManager] track:@"Tapped Menu Option"
                                         properties:@{@"name": @"Profile"}];
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
    if ((self.isMenuOpen && [touch locationInView:self.view].x < MRSLMenuViewWidth) || !_shouldAllowMenuToOpen) {
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
