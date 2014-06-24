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

@property (weak, nonatomic) MRSLUser *user;

@property (weak, nonatomic) IBOutlet UITextField *currentPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation MRSLProfileCredentialsViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.emailField.text = _user.email;

    [[self.navigationItem rightBarButtonItem] setEnabled:[self isDirty]];
}

#pragma mark - Action Methods

- (void)goBack {
    [self.view endEditing:YES];
    
    if ([self isDirty]) {
        [UIAlertView showAlertViewWithTitle:@"Warning"
                                    message:@"You have unsaved changes, are you sure you want to leave?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Discard", nil];
    } else {
        [super goBack];
    }
}

- (BOOL)isDirty {
    return ([self emailChanged] || [self passwordChanged]);
}

- (BOOL)emailChanged {
    return (_user.email) ? ![_user.email isEqualToString:_emailField.text] : (![_emailField.text length] == 0);
}

- (BOOL)passwordChanged {
    return ([_passwordNewField.text length] > 0 || [_confirmNewPasswordField.text length] > 0);
}

- (BOOL)validateEmail {
    if (![self emailChanged]) return YES;
    if ([MRSLUtil validateEmail:_emailField.text]) {
        return YES;
    } else {
        [UIAlertView showAlertViewForErrorString:@"Email must be valid."
                                        delegate:nil];
        return NO;
    }
}

- (BOOL)validatePassword {
    if (![self passwordChanged]) return YES;
    if ([_passwordNewField.text isEqualToString:_confirmNewPasswordField.text]) {
        if ([_passwordNewField.text length] < 8) {
            [UIAlertView showAlertViewForErrorString:@"New password must be at least 8 characters."
                                            delegate:nil];
            return NO;
        } else {
            return YES;
        }
    } else {
        [UIAlertView showAlertViewForErrorString:@"Passwords do not match."
                                        delegate:nil];
        return NO;
    }

    return NO;
}

- (IBAction)saveChanges:(id)sender {
    if (![self isDirty]) return [super goBack];
    if (![self validateCurrentPassword]) return;
    if (![self validateEmail]) return;
    if (![self validatePassword]) return;

    [sender setEnabled:NO];
    __weak __typeof(sender) weakSender = sender;

    [_appDelegate.apiService updateEmail:([self emailChanged] ? _emailField.text : nil)
                                password:_passwordNewField.text
                         currentPassword:_currentPasswordField.text
                                 success:^(id responseObject) {
                                     [UIAlertView showAlertViewWithTitle:@"Success!"
                                                                 message:@"Your account settings have been updated"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                                     [weakSender setEnabled:YES];
                                     [super goBack];
                                 } failure:^(NSError *error) {
                                     DDLogError(@"Error updating User Account Settings");
                                     MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                     [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                      delegate:nil];
                                     [weakSender setEnabled:YES];
                                 }];
}

- (BOOL)validateCurrentPassword {
    BOOL passValid = ([_currentPasswordField.text length] >= 8);
    if (!passValid) {
        [UIAlertView showAlertViewWithTitle:@"Current Password Required"
                                    message:@"For security puposes, please enter your current password to make these changes"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    }
    return passValid;
}

- (IBAction)textChanged:(id)sender {
    [[self.navigationItem rightBarButtonItem] setEnabled:[self isDirty]];
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
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [super goBack];
    }
}

@end
