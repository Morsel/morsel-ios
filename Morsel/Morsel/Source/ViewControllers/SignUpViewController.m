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
#import "ProfileImageView.h"

#import "MRSLUser.h"
#import "UIImage+Resize.h"

@interface SignUpViewController ()

<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;

@property (nonatomic, strong) UIImage *originalProfileImage;

@end

@implementation SignUpViewController

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
    [sender setEnabled:NO];
    
    if ([_firstNameField.text length] == 0 ||
        [_lastNameField.text length] == 0 ||
        !_profileImageView.image)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"All Fields Required"
                                                        message:@"Please fill in all fields and include a profile picture."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    MRSLUser *user = [MRSLUser MR_createInContext:context];
    user.firstName = _firstNameField.text;
    user.lastName = _lastNameField.text;
    user.emailAddress = [NSString stringWithFormat:@"%@-%@@eatmorsel.com", [user.firstName lowercaseString], [user.lastName lowercaseString]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        UIImage *profileImage = [_originalProfileImage thumbnailImage:400.f
                                                 interpolationQuality:kCGInterpolationHigh];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            user.profileImage = UIImageJPEGRepresentation(profileImage, 1.f);
            
            [[ModelController sharedController].morselApiService createUser:user
                                                               withPassword:@"password"
                                                                    success:nil
                                                                    failure:nil];
        });
        
        self.originalProfileImage = nil;
    });
}

- (IBAction)cancelLogin:(UIStoryboardSegue *)segue
{
    // Segue unwind left intentionally blank
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage])
    {
        self.originalProfileImage = info[UIImagePickerControllerOriginalImage];
        
        [self.profileImageView addAndRenderImage:_originalProfileImage];
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
