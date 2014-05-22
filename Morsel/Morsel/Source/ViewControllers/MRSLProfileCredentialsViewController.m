//
//  MRSLProfileCredentialsViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileCredentialsViewController.h"

#import "MRSLAPIService+Profile.h"

#import "MRSLUser.h"

@interface MRSLProfileCredentialsViewController ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *currentPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation MRSLProfileCredentialsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.currentPasswordField setBorderWithColor:[UIColor morselLightContent]
                                         andWidth:1.f];
    [self.passwordNewField setBorderWithColor:[UIColor morselLightContent]
                                     andWidth:1.f];
    [self.confirmNewPasswordField setBorderWithColor:[UIColor morselLightContent]
                                            andWidth:1.f];
    [self.emailField setBorderWithColor:[UIColor morselLightContent]
                               andWidth:1.f];

    self.emailField.text = [MRSLUser currentUser].email;
}

#pragma mark - Action Methods

- (BOOL)validateCurrentPassword {
    BOOL passValid = ([_currentPasswordField.text length] >= 8);
    if (!passValid) {
        [UIAlertView showAlertViewForErrorString:@"Please enter your current password. It must also be at least 8 characters."
                                        delegate:nil];
    }
    return passValid;
}

- (IBAction)changeEmail {
    if (![_emailField.text isEqualToString:[MRSLUser currentUser].email]) {
        if (![self validateCurrentPassword]) return;
        BOOL emailValid = [MRSLUtil validateEmail:_emailField.text];
        if (!emailValid) {
            [UIAlertView showAlertViewForErrorString:@"Email must be valid."
                                            delegate:nil];
            return;
        }

        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService updateEmail:_emailField.text
                                    password:nil
                             currentPassword:_currentPasswordField.text
                                     success:^(id responseObject) {
                                         [UIAlertView showAlertViewWithTitle:@"Success!"
                                                                     message:@"Your email has been updated."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                                         weakSelf.currentPasswordField.text = @"";
                                     } failure:^(NSError *error) {
                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                         [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                          delegate:nil];
                                     }];
    }
}


- (IBAction)changePassword {
    if (![self validateCurrentPassword]) return;
    if ([_confirmNewPasswordField.text isEqualToString:_passwordNewField.text]) {
        BOOL passValid = ([_confirmNewPasswordField.text length] >= 8);
        if (passValid) {
            __weak __typeof(self) weakSelf = self;
            [_appDelegate.apiService updateEmail:nil
                                        password:_confirmNewPasswordField.text
                                 currentPassword:_currentPasswordField.text
                                         success:^(id responseObject) {
                                             [UIAlertView showAlertViewWithTitle:@"Success!"
                                                                         message:@"Your password has been updated."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                                             weakSelf.currentPasswordField.text = @"";
                                             weakSelf.confirmNewPasswordField.text = @"";
                                             weakSelf.passwordNewField.text = @"";
                                         } failure:^(NSError *error) {
                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                             [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                              delegate:nil];
                                         }];
        } else {
            [UIAlertView showAlertViewForErrorString:@"New password must be at least 8 characters."
                                            delegate:nil];
        }
    } else {
        [UIAlertView showAlertViewForErrorString:@"New passwords do not match."
                                        delegate:nil];
    }
}

- (IBAction)logout {
    [UIAlertView showAlertViewWithTitle:@"Logout"
                                message:@"Are you sure you want to logout?"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Yes", nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceShouldLogOutUserNotification
                                                            object:nil];
    }
}

@end
