//
//  MRSLProfileEditFieldsViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileEditFieldsViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLAPIService+Profile.h"

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLProfileEditFieldsViewController ()
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate,
UITextViewDelegate>

@property (weak, nonatomic) MRSLUser *user;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *bioTextView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *requiredFields;

@end

@implementation MRSLProfileEditFieldsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.firstNameField setBorderWithColor:[UIColor morselLightContent]
                                   andWidth:1.f];
    [self.lastNameField setBorderWithColor:[UIColor morselLightContent]
                                  andWidth:1.f];
    [self.bioTextView setBorderWithColor:[UIColor morselLightContent]
                                andWidth:1.f];

    [self populateContent];
}

- (void)populateContent {
    self.user = [MRSLUser currentUser];
    self.profileImageView.user = _user;
    self.usernameLabel.text = _user.username;
    self.firstNameField.text = _user.first_name;
    self.lastNameField.text = _user.last_name;
    self.bioTextView.text = _user.bio;
}

#pragma mark - Action Methods

- (void)updateProfileWithCompletion:(MRSLSuccessBlock)didUpdateOrNil
                            failure:(MRSLFailureBlock)failureOrNil {
    BOOL fieldsFilled = YES;
    for (UITextField *requiredField in _requiredFields) {
        if ([[requiredField text] length] == 0) {
            [requiredField setBorderWithColor:[UIColor morselRed]
                                     andWidth:2.f];
            fieldsFilled = NO;
        } else {
            [requiredField setBorderWithColor:[UIColor morselLightContent]
                                     andWidth:1.f];
        }
    }
    if (!fieldsFilled) {
        [UIAlertView showAlertViewForErrorString:@"Please fill in all fields."
                                        delegate:nil];
        if (failureOrNil) failureOrNil(nil);
        return;
    }

    BOOL userDidUpdate = (_user.first_name) ? ![_user.first_name isEqualToString:_firstNameField.text] : ([_firstNameField.text length] != 0);
    userDidUpdate = (_user.last_name) ? ![_user.last_name isEqualToString:_lastNameField.text] : ([_lastNameField.text length] != 0);
    userDidUpdate = (_user.bio) ? ![_user.bio isEqualToString:_bioTextView.text] : (![_bioTextView.text length] == 0);

    if (userDidUpdate) {
        _user.first_name = _firstNameField.text;
        _user.last_name = _lastNameField.text;
        _user.bio = _bioTextView.text;

        [_appDelegate.apiService updateUser:_user
                                    success:^(id responseObject) {
                                        if (didUpdateOrNil) didUpdateOrNil(YES);
                                    } failure:failureOrNil];
    } else {
        if (didUpdateOrNil) didUpdateOrNil(NO);
    }
}

- (IBAction)addPhoto {
    [[MRSLEventManager sharedManager] track:@"Tapped Add Photo Icon"
                                 properties:@{@"view": @"Sign up"}];

    [self.view endEditing:YES];

    UIActionSheet *profileActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a Profile Photo"
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Take Photo", @"Select from Library", nil];

    [profileActionSheet setCancelButtonIndex:[profileActionSheet addButtonWithTitle:@"Cancel"]];

    [profileActionSheet showInView:self.containingView ?: self.view];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger textLength = (textView.text.length - range.length) + text.length;
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else if (textLength > 255) {
        return NO;
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) return;

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
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
        UIImage *originalProfileImage = info[UIImagePickerControllerEditedImage];
        [self.profileImageView addAndRenderImage:originalProfileImage
                                        complete:nil];
        [self.activityIndicatorView startAnimating];
        self.editPhotoButton.hidden = YES;

        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *profileImageFull = [originalProfileImage thumbnailImage:originalProfileImage.size.width
                                                        interpolationQuality:kCGInterpolationHigh];
            UIImage *profileImageLarge = [profileImageFull thumbnailImage:MRSLUserProfileImageLargeDimensionSize
                                                     interpolationQuality:kCGInterpolationHigh];
            UIImage *profileImageThumb = [profileImageFull thumbnailImage:MRSLUserProfileImageThumbDimensionSize
                                                     interpolationQuality:kCGInterpolationHigh];
            weakSelf.user.profilePhotoLarge = UIImageJPEGRepresentation(profileImageLarge, 1.f);
            weakSelf.user.profilePhotoThumb = UIImageJPEGRepresentation(profileImageThumb, 1.f);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.user.profilePhotoFull = UIImageJPEGRepresentation(profileImageFull, 1.f);
                [_appDelegate.apiService updateUser:weakSelf.user success:^(id responseObject) {
                    weakSelf.editPhotoButton.hidden = NO;
                    [weakSelf.activityIndicatorView stopAnimating];
                    weakSelf.profileImageView.user = weakSelf.user;
                } failure:^(NSError *error) {
                    weakSelf.editPhotoButton.hidden = NO;
                    [weakSelf.activityIndicatorView stopAnimating];
                }];
            });
        });
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
