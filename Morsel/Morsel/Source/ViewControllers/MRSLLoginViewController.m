//
//  LoginViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLLoginViewController.h"

#import "JSONResponseSerializerWithData.h"

static const CGFloat MRSLLoginScrollViewHeight = 508.f;
static const CGFloat MRSLLoginContentHeight = 385.f;

@interface MRSLLoginViewController ()
<UITextFieldDelegate>

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

#if (defined(MORSEL_BETA))
    self.backButton.hidden = YES;
#endif

    self.loginScrollView.contentSize = CGSizeMake([self.view getWidth], MRSLLoginContentHeight);

    [self.emailTextField setBorderWithColor:[UIColor morselLightContent]
                                   andWidth:1.f];
    [self.passwordTextField setBorderWithColor:[UIColor morselLightContent]
                                      andWidth:1.f];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Private Methods

- (IBAction)logIn {
    [[MRSLEventManager sharedManager] track:@"Tapped Log in"
                          properties:@{@"view": @"Log in"}];

    BOOL emailValid = [MRSLUtil validateEmail:_emailTextField.text];
    BOOL passValid = ([_passwordTextField.text length] >= 8);

    if (!emailValid || !passValid) {
        [UIAlertView showAlertViewWithTitle:@"Invalid Email or Password"
                                    message:@"Email must be valid. Password must be at least 8 characters."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
        return;
    }

    [self.signInButton setEnabled:NO];

    self.activityView.hidden = NO;

    [_appDelegate.itemApiService signInUserWithEmail:_emailTextField.text
                                          andPassword:_passwordTextField.text
                                              success:nil
                                              failure:^(NSError *error)
     {
         self.activityView.hidden = YES;
         [self.signInButton setEnabled:YES];

         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

         [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                          delegate:nil];
     }];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.loginScrollView setHeight:[self.view getHeight] - keyboardSize.height];
                         [self.loginScrollView scrollRectToVisible:CGRectMake(0.f, MRSLLoginContentHeight - 5.f, 5.f, 5.f)
                                                          animated:YES];
                     }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.loginScrollView setHeight:MRSLLoginScrollViewHeight];
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
