//
//  SignUpViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSignUpViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "MRSLStandardButton.h"
#import "JSONResponseSerializerWithData.h"
#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

static const CGFloat MRSLSignUpScrollViewHeight = 448.f;
static const CGFloat MRSLSignUpContentHeight = 440.f;

@interface MRSLSignUpViewController ()
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MRSLStandardButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *occupationTitleField;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (strong, nonatomic) UIImage *originalProfileImage;

@end

@implementation MRSLSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#if (defined(MORSEL_BETA))
    [self performSegueWithIdentifier:@"seg_DisplayLogin"
                              sender:nil];
#endif

    [self.profileImageView setBorderWithColor:[UIColor morselLightContent]
                                     andWidth:1.f];
    [self.usernameField setBorderWithColor:[UIColor morselLightContent]
                                  andWidth:1.f];
    [self.passwordField setBorderWithColor:[UIColor morselLightContent]
                                  andWidth:1.f];
    [self.emailField setBorderWithColor:[UIColor morselLightContent]
                               andWidth:1.f];
    [self.firstNameField setBorderWithColor:[UIColor morselLightContent]
                                   andWidth:1.f];
    [self.lastNameField setBorderWithColor:[UIColor morselLightContent]
                                  andWidth:1.f];
    [self.occupationTitleField setBorderWithColor:[UIColor morselLightContent]
                                         andWidth:1.f];

    self.contentScrollView.contentSize = CGSizeMake([self.view getWidth], MRSLSignUpContentHeight);

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

- (IBAction)addPhoto:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Add Photo Icon"
                                 properties:@{@"view": @"Sign up"}];

    [self.view endEditing:YES];

    UIActionSheet *profileActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a Profile Photo"
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Take Photo", @"Select from Library", nil];

    [profileActionSheet setCancelButtonIndex:[profileActionSheet addButtonWithTitle:@"Cancel"]];

    [profileActionSheet showInView:self.view];
}

- (IBAction)signUp {
    [[MRSLEventManager sharedManager] track:@"Tapped Sign up"
                                 properties:@{@"view": @"Sign up"}];

    BOOL usernameValid = [MRSLUtil validateUsername:_usernameField.text];
    BOOL emailValid = [MRSLUtil validateEmail:_emailField.text];
    BOOL passValid = ([_passwordField.text length] >= 8);

    if (!usernameValid || !emailValid || !passValid) {
        [UIAlertView showAlertViewWithTitle:@"Invalid Username, Email, or Password"
                                    message:@"Username and Email must be valid. Password must be at least 8 characters."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
        return;
    }

    if ([_usernameField.text length] == 0 ||
        [_passwordField.text length] == 0 ||
        [_emailField.text length] == 0 ||
        [_firstNameField.text length] == 0 ||
        [_lastNameField.text length] == 0 ||
        [_occupationTitleField.text length] == 0 ||
        !_profileImageView.image) {
        [UIAlertView showAlertViewWithTitle:@"All Fields Required"
                                    message:@"Please fill in all fields and include a profile picture."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
        return;
    }

    [_continueButton setEnabled:NO];

    self.activityView.hidden = NO;

    MRSLUser *user = [MRSLUser MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    user.first_name = _firstNameField.text;
    user.last_name = _lastNameField.text;
    user.username = _usernameField.text;
    user.email = _emailField.text;
    user.title = _occupationTitleField.text;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *profileImageFull = [_originalProfileImage thumbnailImage:_originalProfileImage.size.width
                                                     interpolationQuality:kCGInterpolationHigh];
        UIImage *profileImageLarge = [profileImageFull thumbnailImage:MRSLUserProfileImageLargeDimensionSize
                                                 interpolationQuality:kCGInterpolationHigh];
        UIImage *profileImageThumb = [profileImageFull thumbnailImage:MRSLUserProfileImageThumbDimensionSize
                                                 interpolationQuality:kCGInterpolationHigh];
        user.profilePhotoLarge = UIImageJPEGRepresentation(profileImageLarge, 1.f);
        user.profilePhotoThumb = UIImageJPEGRepresentation(profileImageThumb, 1.f);

        dispatch_async(dispatch_get_main_queue(), ^{
            user.profilePhotoFull = UIImageJPEGRepresentation(profileImageFull, 1.f);

            [_appDelegate.itemApiService createUser:user
                                         withPassword:_passwordField.text
                                              success:nil
                                              failure:^(NSError *error)
             {
                 self.activityView.hidden = YES;
                 [self.continueButton setEnabled:YES];

                 MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

                 [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                  delegate:nil];
             }];
        });

        self.originalProfileImage = nil;
    });
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.contentScrollView setHeight:[self.view getHeight] - keyboardSize.height];
                     }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.contentScrollView setHeight:MRSLSignUpScrollViewHeight];
                     }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) return;

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Take Photo"
                                     properties:@{@"view": @"Sign up"}];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        [[MRSLEventManager sharedManager] track:@"Tapped Select From Library"
                                     properties:@{@"view": @"Sign up"}];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    imagePicker.delegate = self;

    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        [[MRSLEventManager sharedManager] track:@"Added Photo"
                                     properties:@{@"view": @"Sign up"}];

        self.originalProfileImage = info[UIImagePickerControllerOriginalImage];

        [self.profileImageView addAndRenderImage:_originalProfileImage];

        _addPhotoButton.hidden = YES;
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[MRSLEventManager sharedManager] track:@"Tapped Cancel"
                                 properties:@{@"view": @"Sign up"}];
    [self dismissViewControllerAnimated:YES
                             completion:nil];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect centeredFrame = textField.frame;
    centeredFrame.origin.y = textField.frame.origin.y - (self.contentScrollView.frame.size.height / 2);

    [self.contentScrollView scrollRectToVisible:centeredFrame
                                       animated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:_usernameField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Username Field"
                                     properties:@{@"view": @"Sign up"}];
    } else if ([textField isEqual:_passwordField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Password Field"
                                     properties:@{@"view": @"Sign up"}];
    } else if ([textField isEqual:_emailField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Email Field"
                                     properties:@{@"view": @"Sign up"}];
    } else if ([textField isEqual:_firstNameField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped First Name Field"
                                     properties:@{@"view": @"Sign up"}];
    } else if ([textField isEqual:_lastNameField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Last Name Field"
                                     properties:@{@"view": @"Sign up"}];
    } else if ([textField isEqual:_occupationTitleField]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Title Field"
                                     properties:@{@"view": @"Sign up"}];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        if ([textField isEqual:_usernameField]) {
            [_passwordField becomeFirstResponder];
        } else if ([textField isEqual:_passwordField]) {
            [_emailField becomeFirstResponder];
        } else if ([textField isEqual:_emailField]) {
            [_firstNameField becomeFirstResponder];
        } else if ([textField isEqual:_firstNameField]) {
            [_lastNameField becomeFirstResponder];
        } else if ([textField isEqual:_lastNameField]) {
            [_occupationTitleField becomeFirstResponder];
        } else if ([textField isEqual:_occupationTitleField]) {
            [textField resignFirstResponder];
            [self signUp];
            [self.contentScrollView scrollRectToVisible:CGRectMake(0.f, 0.f, 5.f, 5.f)
                                               animated:YES];
        }

        return NO;
    } else {
        CGRect centeredFrame = textField.frame;
        centeredFrame.origin.y = textField.frame.origin.y - (self.contentScrollView.frame.size.height / 2);

        [self.contentScrollView scrollRectToVisible:centeredFrame
                                           animated:YES];

        return YES;
    }

    return YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
