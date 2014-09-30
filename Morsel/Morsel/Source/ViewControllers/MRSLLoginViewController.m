//
//  LoginViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLLoginViewController.h"

#import "MRSLAPIService+Authentication.h"
#import "MRSLAPIService+Registration.h"

#import "MRSLSocialAuthentication.h"
#import "MRSLSocialUser.h"

@interface MRSLLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation MRSLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"email_login";

    if (_socialUser) {
        self.emailTextField.text = _socialUser.email;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    [super viewWillAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Private Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:MRSLStoryboardSegueDisplayResetPasswordKey]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Forgot Password",
                                                  @"_view": self.mp_eventView}];
    }
}

- (void)showInvalidLoginAlert {
    [UIAlertView showAlertViewWithTitle:@"Invalid Login"
                                message:@"Check your credentials and try again"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles:nil];
}

- (BOOL)validateFields {
    if ([_passwordTextField.text length] < 8) return NO;

    if ([_emailTextField.text rangeOfString:@"@"].location == NSNotFound)
        return [MRSLUtil validateUsername:_emailTextField.text];
    else
        return [MRSLUtil validateEmail:_emailTextField.text];
}

- (IBAction)logIn {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Log in",
                                              @"_view": self.mp_eventView}];

    //  We shouldn't care too much about validation on the login page and just let them throw whatever
    if (![self validateFields]) {
        [self showInvalidLoginAlert];
        return;
    }

    [self.signInButton setEnabled:NO];
    [self.view showActivityViewWithMode:RNActivityViewModeIndeterminate
                                  label:@"Logging in"
                            detailLabel:nil];

    // Just making sure that any social connections enabled are either permanently or temporarily cleared.
    // After login, app will use authentications from backend to re-establish them
    [_appDelegate resetSocialConnections];

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService signInUserWithEmailOrUsername:_emailTextField.text
                                               andPassword:_passwordTextField.text
                                          orAuthentication:nil
                                                   success:^(id responseObject) {
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayOnboardingNotification object:nil];
                                                       });

                                                       [[MRSLEventManager sharedManager] track:@"User logged in"
                                                                                    properties:@{@"_view": self.mp_eventView,
                                                                                                 @"auth_type": (weakSelf.socialUser.authentication) ? NSNullIfNil(weakSelf.socialUser.authentication.provider) : @"email"}];
                                                       if (weakSelf.socialUser) {
                                                           [_appDelegate.apiService createUserAuthentication:weakSelf.socialUser.authentication
                                                                                                     success:^(id responseObject) {
                                                                                                         [_appDelegate.apiService getUserAuthenticationsWithSuccess:nil
                                                                                                                                                            failure:nil];
                                                                                                     } failure:nil];
                                                       } else {
                                                           [_appDelegate.apiService getUserAuthenticationsWithSuccess:nil
                                                                                                              failure:nil];
                                                       }
                                                   } failure:^(NSError *error) {
                                                       [weakSelf.view hideActivityView];
                                                       [weakSelf.signInButton setEnabled:YES];

                                                       MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                       [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                                        delegate:nil];
                                                   }];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {

        if ([textField isEqual:_emailTextField]) {
            [_passwordTextField becomeFirstResponder];
        } else if ([textField isEqual:_passwordTextField]) {
            [textField resignFirstResponder];
            [self logIn];
        }
        return NO;
    } else {
        return YES;
    }
    
    return YES;
}

@end
