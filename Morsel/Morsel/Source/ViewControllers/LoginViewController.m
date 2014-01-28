//
//  LoginViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "LoginViewController.h"

#import "ModelController.h"

@interface LoginViewController ()

<
UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation LoginViewController

#pragma mark - Private Methods

- (IBAction)logIn
{
    BOOL emailValid = [Util validateEmail:_emailTextField.text];
    BOOL passValid = ([_passwordTextField.text length] >= 8);
    
    if (!emailValid || !passValid)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email or Password"
                                                        message:@"Email must be valid. Password must be at least 8 characters."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [self.signInButton setEnabled:NO];
    
    self.activityView.hidden = NO;
    
    [[ModelController sharedController].morselApiService signInUserWithEmail:_emailTextField.text
                                                                 andPassword:_passwordTextField.text
                                                                     success:nil
                                                                     failure:^(NSError *error) {
                                                                         self.activityView.hidden = YES;
                                                                         [self.signInButton setEnabled:YES];
                                                                     }];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self logIn];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    else
    {
        return YES;
    }
    
    return YES;
}

@end
