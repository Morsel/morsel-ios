//
//  MRSLResetPasswordViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLResetPasswordViewController.h"

#import "MRSLAPIService+Registration.h"

@interface MRSLResetPasswordViewController ()
<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameEmailField;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;

@end

@implementation MRSLResetPasswordViewController

#pragma mark - Action Methods

- (IBAction)resetPassword {
    [[MRSLEventManager sharedManager] track:@"Tapped Reset Password"
                                 properties:@{@"view": @"Forgot password"}];
    if (![MRSLUtil validateEmail:_usernameEmailField.text]) {
        [UIAlertView showAlertViewWithTitle:@"Invalid Email"
                                    message:@"Email must be valid."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
        return;
    }

    [self.resetButton setEnabled:NO];

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService forgotPasswordWithEmail:_usernameEmailField.text
                                             success:^(id responseObject) {
                                                 [UIView animateWithDuration:.4f animations:^{
                                                     [weakSelf.resetButton setAlpha:0.f];
                                                     [weakSelf.usernameEmailField setAlpha:0.f];
                                                 }];
                                                 [UIView animateWithDuration:.4f
                                                                       delay:.2f
                                                                     options:UIViewAnimationOptionCurveLinear
                                                                  animations:^{
                                                     [weakSelf.successLabel setAlpha:1.f];
                                                 } completion:nil];
    } failure:^(NSError *error) {
        [self.resetButton setEnabled:YES];
    }];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:_usernameEmailField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Username/Email Field"
                                     properties:@{@"view": @"Reset Password"}];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        if ([textField isEqual:_usernameEmailField]) {
            [textField resignFirstResponder];
            [self resetPassword];
        }
        return NO;
    } else {
        return YES;
    }

    return YES;
}

@end
