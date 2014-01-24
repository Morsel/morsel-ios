//
//  SignUpViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "SignUpViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "ModelController.h"
#import "MorselStandardButton.h"
#import "ProfileImageView.h"

#import "MRSLUser.h"

@interface SignUpViewController ()

<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet MorselStandardButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *occupationTitleField;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (nonatomic, strong) UIImage *originalProfileImage;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_profileImageView addCornersWithRadius:36.f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Private Methods

- (IBAction)addPhoto:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    imagePicker.allowsEditing = NO;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (IBAction)continue:(UIButton *)sender
{
    BOOL usernameValid = [Util validateUsername:_usernameField.text];
    BOOL emailValid = [Util validateEmail:_emailField.text];
    BOOL passValid = ([_passwordField.text length] >= 8);
    
    if (!usernameValid ||
        !emailValid ||
        !passValid)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Username, Email or Password"
                                                        message:@"Username and Email must be valid. Password must be at least 8 characters."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([_usernameField.text length] == 0 ||
        [_passwordField.text length] == 0 ||
        [_emailField.text length] == 0 ||
        [_firstNameField.text length] == 0 ||
        [_lastNameField.text length] == 0 ||
        [_occupationTitleField.text length] == 0 ||
        !_profileImageView.image)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"All Fields Required"
                                                        message:@"Please fill in all fields and include a profile picture."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [sender setEnabled:NO];
    
    self.activityView.hidden = NO;
    
    MRSLUser *user = [MRSLUser MR_createInContext:[ModelController sharedController].defaultContext];
    user.firstName = _firstNameField.text;
    user.lastName = _lastNameField.text;
    user.userName = _usernameField.text;
    user.emailAddress = _emailField.text;
    user.occupationTitle = _occupationTitleField.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        UIImage *profileImage = [_originalProfileImage thumbnailImage:_originalProfileImage.size.width
                                                 interpolationQuality:kCGInterpolationHigh];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            user.profileImage = UIImageJPEGRepresentation(profileImage, 1.f);
            
            [[ModelController sharedController].morselApiService createUser:user
                                                               withPassword:_passwordField.text
                                                                    success:nil
                                                                    failure:^(NSError *error)
            {
                self.activityView.hidden = YES;
                [sender setEnabled:YES];
            }];
        });
        
        self.originalProfileImage = nil;
    });
}

- (IBAction)cancelLogin:(UIStoryboardSegue *)segue
{
    // Segue unwind left intentionally blank
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:.2f animations:^
    {
        [self.contentScrollView setHeight:self.view.frame.size.height - keyboardSize.height];
    }];
    
    [self.contentScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - _continueButton.frame.size.height)];
}

- (void)keyboardWillHide
{
    [UIView animateWithDuration:.2f animations:^
     {
         [self.contentScrollView setHeight:self.view.frame.size.height];
     }];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage])
    {
        self.originalProfileImage = info[UIImagePickerControllerOriginalImage];
        
        [self.profileImageView addAndRenderImage:_originalProfileImage];
        
        _addPhotoButton.hidden = YES;
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect centeredFrame = textField.frame;
    centeredFrame.origin.y = textField.frame.origin.y - (self.contentScrollView.frame.size.height / 2);
    
    [self.contentScrollView scrollRectToVisible:centeredFrame
                                       animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    CGRect centeredFrame = textField.frame;
    centeredFrame.origin.y = textField.frame.origin.y - (self.contentScrollView.frame.size.height / 2);
    
    [self.contentScrollView scrollRectToVisible:centeredFrame
                                       animated:YES];
    
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
