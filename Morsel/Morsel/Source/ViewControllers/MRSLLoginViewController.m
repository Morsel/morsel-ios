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

#import "MRSLSocialUser.h"

@interface MRSLLoginViewController ()
<UITextFieldDelegate>

@property (nonatomic) CGFloat scrollViewHeight;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;

@end

@implementation MRSLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_socialUser) {
        self.emailTextField.text = _socialUser.email;
    }

    [self.emailTextField setBorderWithColor:[UIColor morselLightContent]
                                   andWidth:1.f];
    [self.passwordTextField setBorderWithColor:[UIColor morselLightContent]
                                      andWidth:1.f];

    self.scrollViewHeight = [self.loginScrollView getHeight];
    [self.loginScrollView setContentSize:CGSizeMake([self.loginScrollView getWidth], ([_signInButton getHeight] + [_signInButton getY] + 20.f))];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
    [[MRSLEventManager sharedManager] track:@"Tapped Log in"
                                 properties:@{@"view": @"Log in"}];

    //  We shouldn't care too much about validation on the login page and just let them throw whatever
    if (![self validateFields]) {
        [self showInvalidLoginAlert];
        return;
    }

    [self.signInButton setEnabled:NO];
    [self.activityView setHidden:NO];

    // Just making sure that any social connections enabled are either permanently or temporarily cleared.
    // After login, app will use authentications from backend to re-establish them
    [_appDelegate resetSocialConnections];

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService signInUserWithEmailOrUsername:_emailTextField.text
                                               andPassword:_passwordTextField.text
                                          orAuthentication:nil
                                                   success:^(id responseObject) {
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
                                                       [weakSelf.activityView setHidden:YES];
                                                       [weakSelf.signInButton setEnabled:YES];

                                                       MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                       [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                                        delegate:nil];
                                                   }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.loginScrollView setHeight:[self.view getHeight] - keyboardSize.height];
                     }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.loginScrollView setHeight:_scrollViewHeight];
                     }];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:_emailTextField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Email Field"
                                     properties:@{@"view": @"Log in"}];
    } else if ([textField isEqual:_passwordTextField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Password Field"
                                     properties:@{@"view": @"Log in"}];
    }
    return YES;
}

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

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
