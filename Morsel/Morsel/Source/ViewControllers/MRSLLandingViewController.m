//
//  MRSLLandingViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLLandingViewController.h"

#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceTwitter.h"
#import "MRSLAPIService+Authentication.h"
#import "MRSLAPIService+Registration.h"

#import "MRSLLoginViewController.h"
#import "MRSLSignUpViewController.h"

#import "MRSLUser.h"
#import "MRSLSocialUser.h"

@interface MRSLLandingViewController ()
<UIAlertViewDelegate>

@property (nonatomic) BOOL shouldOmitEmailFromSignUp;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *guestButton;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (strong, nonatomic) MRSLSocialUser *socialUser;

@end

@implementation MRSLLandingViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"welcome";

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    [super viewWillAppear:animated];
    self.shouldOmitEmailFromSignUp = NO;
    self.socialUser = nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Action Methods

- (IBAction)connectWithFacebook {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Connect with Facebook",
                                              @"_view": self.mp_eventView}];
    self.activityView.hidden = NO;
    if ([FBSession.activeSession isOpen]) {
        [self connectFacebookAccountUsingActiveSession];
    } else {
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceFacebook sharedService] openFacebookSessionWithSessionStateHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if ([session isOpen]) {
                [weakSelf connectFacebookAccountUsingActiveSession];
            } else {
                weakSelf.activityView.hidden = YES;
            }
        }];
    }
}

- (IBAction)connectWithTwitter {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Connect with Twitter",
                                              @"_view": self.mp_eventView}];
    self.activityView.hidden = NO;
    if ([MRSLSocialServiceTwitter sharedService].oauth1Client.accessToken) {
        [self connectTwitterAccountUsingActiveSession];
    } else {
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceTwitter sharedService] authenticateWithTwitterWithSuccess:^(BOOL success) {
            if (success) {
                [weakSelf connectTwitterAccountUsingActiveSession];
            } else {
                weakSelf.activityView.hidden = YES;
            }
        } failure:^(NSError *error) {
            weakSelf.activityView.hidden = YES;
            if (error) [UIAlertView showAlertViewForError:error
                                                 delegate:nil];
        }];
    }
}

- (IBAction)signUpWithEmail {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Use my email address",
                                              @"_view": self.mp_eventView}];
    [self performSegueWithIdentifier:MRSLStoryboardSegueDisplaySignUpKey
                              sender:nil];
}

- (IBAction)continueAsGuest {
    [MRSLUser createGuestUser];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - Social Methods

- (void)connectFacebookAccountUsingActiveSession {
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceFacebook sharedService] getFacebookUserInformation:^(NSDictionary *userInfo, NSError *error) {
        weakSelf.socialUser = [[MRSLSocialUser alloc] initWithUserInfo:userInfo];
        [_appDelegate.apiService checkAuthentication:_socialUser.authentication
                                              exists:^(BOOL exists, NSError *error) {
                                                  if (exists) {
                                                      // Log user in and party.
                                                      [_appDelegate.apiService signInUserWithEmailOrUsername:nil
                                                                                                 andPassword:nil
                                                                                            orAuthentication:_socialUser.authentication
                                                                                                     success:^(id responseObject) {
                                                                                                         weakSelf.activityView.hidden = YES;
                                                                                                     } failure:^(NSError *error) {
                                                                                                         weakSelf.activityView.hidden = YES;
                                                                                                     }];
                                                  } else {
                                                      // Facebook account not associated with any Morsel accounts. Check if email is.
                                                      [_appDelegate.apiService checkEmail:_socialUser.email
                                                                                   exists:^(BOOL exists, NSError *error) {
                                                                                       weakSelf.activityView.hidden = YES;
                                                                                       if (exists) {
                                                                                           // If it does, present "connect to existing account" page. Pass Facebook user object
                                                                                           UIAlertView *alert = [UIAlertView showAlertViewWithTitle:@"Email Account Found"
                                                                                                                                            message:[NSString stringWithFormat:@"An account with email (%@) already exists. Please confirm your password to link your account with Facebook.", _socialUser.email]
                                                                                                                                           delegate:weakSelf
                                                                                                                                  cancelButtonTitle:@"Cancel"
                                                                                                                                  otherButtonTitles:@"OK", nil];
                                                                                           [alert setTag:MRSLSocialAlertViewTypeFacebook];
                                                                                       } else {
                                                                                           // If it doesn't, display sign up with prefilled Facebook user data
                                                                                           [weakSelf performSegueWithIdentifier:MRSLStoryboardSegueDisplaySignUpKey
                                                                                                                         sender:nil];
                                                                                       }
                                                                                   }];
                                                  }
                                              }];
    }];
}

- (void)connectTwitterAccountUsingActiveSession {
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceTwitter sharedService] getTwitterUserInformation:^(NSDictionary *userInfo, NSError *error) {
        weakSelf.socialUser = [[MRSLSocialUser alloc] initWithUserInfo:userInfo];
        [_appDelegate.apiService checkAuthentication:_socialUser.authentication
                                              exists:^(BOOL exists, NSError *error) {
                                                  if (exists) {
                                                      // Log user in and party.
                                                      [_appDelegate.apiService signInUserWithEmailOrUsername:nil
                                                                                                 andPassword:nil
                                                                                            orAuthentication:_socialUser.authentication
                                                                                                     success:^(id responseObject) {
                                                                                                         weakSelf.activityView.hidden = YES;
                                                                                                     } failure:^(NSError *error) {
                                                                                                         weakSelf.activityView.hidden = YES;
                                                                                                     }];
                                                  } else {
                                                      weakSelf.activityView.hidden = YES;
                                                      // If it doesn't, display sign up with prefilled Twitter user data
                                                      [weakSelf performSegueWithIdentifier:MRSLStoryboardSegueDisplaySignUpKey
                                                                                    sender:nil];
                                                  }
                                              }];
    }];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:MRSLStoryboardSegueDisplaySignUpKey]) {
        MRSLSignUpViewController *signUpVC = [segue destinationViewController];
        if (_socialUser) signUpVC.socialUser = _socialUser;
        if (_shouldOmitEmailFromSignUp) signUpVC.shouldOmitEmail = _shouldOmitEmailFromSignUp;
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSegueDisplayLoginKey]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Log in",
                                                  @"_view": self.mp_eventView}];
        MRSLLoginViewController *loginVC = [segue destinationViewController];
        if (_socialUser) loginVC.socialUser = _socialUser;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        // Display sign up without email
        self.shouldOmitEmailFromSignUp = YES;
        [self performSegueWithIdentifier:MRSLStoryboardSegueDisplaySignUpKey
                                  sender:nil];
    } else {
        // Display log in with prefilled email
        [self performSegueWithIdentifier:MRSLStoryboardSegueDisplayLoginKey
                                  sender:nil];
    }
}

@end
