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

#import "MRSLActivityIndicatorView.h"
#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLProfileEditFieldsViewController ()
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate,
UITextViewDelegate,
UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (weak, nonatomic) IBOutlet MRSLActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *bioTextView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *requiredFields;

@property (nonatomic) CGFloat scrollViewHeight;
@property (nonatomic) BOOL photoChanged;

@end

@implementation MRSLProfileEditFieldsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_user) self.user = [MRSLUser currentUser];

    self.scrollViewHeight = [_contentScrollView getHeight];
    self.bioTextView.placeholder = @"Tell us about yourself";
    [self.contentScrollView setContentSize:CGSizeMake([_contentScrollView getWidth], (CGRectGetMaxY(_bioTextView.frame) + 20.f))];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _photoChanged = NO;
    [self populateContent];
    [[self.navigationItem rightBarButtonItem] setEnabled:[self isDirty]];
}

- (void)populateContent {
    self.profileImageView.user = _user;
    self.usernameLabel.text = _user.username;
    self.firstNameField.text = _user.first_name;
    self.lastNameField.text = _user.last_name;
    self.bioTextView.text = _user.bio;
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
                         [self.contentScrollView setHeight:_scrollViewHeight];
                     }];
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

- (void)updateProfileWithCompletion:(MRSLSuccessBlock)didUpdateOrNil
                            failure:(MRSLFailureBlock)failureOrNil {
    BOOL fieldsFilled = YES;
    for (UITextField *requiredField in _requiredFields) {
        if ([[requiredField text] length] == 0) {
            [requiredField setBorderWithColor:[UIColor morselPrimary]
                                     andWidth:2.f];
            fieldsFilled = NO;
        } else {
            [requiredField removeBorder];
        }
    }

    if (!fieldsFilled) {
        [UIAlertView showAlertViewForErrorString:@"Please fill in all highlighted fields."
                                        delegate:nil];
        if (failureOrNil) failureOrNil(nil);
        return;
    }

    if ([self isDirty]) {
        if ([self firstNameChanged]) _user.first_name = _firstNameField.text;
        if ([self lastNameChanged]) _user.last_name = _lastNameField.text;
        if ([self bioChanged]) _user.bio = _bioTextView.text;
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService updateUser:_user
                                    success:^(id responseObject) {
                                        MRSLUser *updatedUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                        withValue:responseObject[@"data"][@"id"]];
                                        if (weakSelf.photoChanged) {
                                            [updatedUser API_updateImage];
                                        }

                                        if (didUpdateOrNil) didUpdateOrNil(YES);
                                    } failure:^(NSError *error) {
                                        MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                        [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                         delegate:nil];
                                        if (failureOrNil) failureOrNil(error);
                                    }];
    } else {
        if (didUpdateOrNil) didUpdateOrNil(NO);
    }
}

- (BOOL)isDirty {
    return ([self firstNameChanged] || [self lastNameChanged] || [self bioChanged] || [self photoChanged]);
}

- (BOOL)firstNameChanged {
    return (_user.first_name) ? ![_user.first_name isEqualToString:_firstNameField.text] : ([_firstNameField.text length] != 0);
}

- (BOOL)lastNameChanged {
    return (_user.last_name) ? ![_user.last_name isEqualToString:_lastNameField.text] : ([_lastNameField.text length] != 0);
}

- (BOOL)bioChanged {
    return (_user.bio) ? ![_user.bio isEqualToString:_bioTextView.text] : (![_bioTextView.text length] == 0);
}

- (IBAction)saveChanges:(id)sender {
    if (![self isDirty]) return [super goBack];

    [sender setEnabled:NO];
    __weak __typeof(self) weakSelf = self;
    __weak __typeof(sender) weakSender = sender;

    [self updateProfileWithCompletion:^(BOOL success) {
        [UIAlertView showAlertViewWithTitle:@"Success!"
                                    message:@"Your profile has been updated"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        weakSelf.profileImageView.user = weakSelf.user;
        [weakSender setEnabled:YES];
        [super goBack];
    } failure:^(NSError *error) {
        DDLogError(@"Error updating User Profile");
        [weakSender setEnabled:YES];
    }];
}

- (IBAction)changePhoto {
    [[MRSLEventManager sharedManager] track:@"Tapped Change Photo Icon"
                                 properties:@{@"view": @"Edit Profile"}];

    [self.view endEditing:YES];

    UIActionSheet *profileActionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Profile Photo"
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Take Photo", @"Select from Library", nil];

    [profileActionSheet setCancelButtonIndex:[profileActionSheet addButtonWithTitle:@"Cancel"]];

    [profileActionSheet showInView:self.containingView ?: self.view];
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

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self textChanged:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger textLength = (textView.text.length - range.length) + text.length;
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else if (textLength > 160) {
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
                [weakSelf.activityIndicatorView stopAnimating];
                weakSelf.photoChanged = YES;
                [[weakSelf.navigationItem rightBarButtonItem] setEnabled:[self isDirty]];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [super goBack];
    }
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.bioTextView.delegate = nil;
    self.bioTextView.placeholder = nil;
    self.bioTextView.placeholderColor = nil;
}

@end
