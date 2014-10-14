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
#import "MRSLBaseViewController+Additions.h"

#import "MRSLActivityIndicatorView.h"
#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLProfileEditFieldsViewController ()
<UITextFieldDelegate,
UITextViewDelegate,
UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *bioTextView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *requiredFields;

@property (nonatomic) BOOL photoChanged;

@end

@implementation MRSLProfileEditFieldsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"Edit profile";

    if (!_user) self.user = [MRSLUser currentUser];

    self.bioTextView.placeholder = @"Tell us about yourself";

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

#pragma mark - Action Methods

- (void)goBack {
    [self.view endEditing:YES];

    if ([self isDirty]) {
        [UIAlertView showAlertViewWithTitle:@"Warning"
                                    message:@"You have unsaved changes, are you sure you want to discard them?"
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
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Change Photo",
                                              @"_view": self.mp_eventView}];

    [self displayMediaActionSheetWithTitle:@"Change profile photo"
                 withPreferredDeviceCamera:UIImagePickerControllerCameraDeviceFront];
}

- (IBAction)textChanged:(id)sender {
    [[self.navigationItem rightBarButtonItem] setEnabled:[self isDirty]];
}

#pragma mark - Media Methods

- (void)processMediaItem:(MRSLMediaItem *)mediaItem {
    [self.profileImageView addAndRenderImage:mediaItem.mediaFullImage
                                    complete:nil];

    __block UIImage *fullSizeImage = mediaItem.mediaFullImage;
    [self.view showActivityViewWithMode:RNActivityViewModeIndeterminate
                                  label:@"Processing image"
                            detailLabel:nil];
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.eatmorsel.profile-image-processing", NULL);
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        mediaItem.mediaFullImage = [fullSizeImage thumbnailImage:MIN(MRSLImageFullDimensionSize, mediaItem.mediaFullImage.size.width)
                                            interpolationQuality:kCGInterpolationHigh];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(queue, ^{
                mediaItem.mediaLargeImage = [fullSizeImage thumbnailImage:MRSLUserProfileImageLargeDimensionSize
                                                     interpolationQuality:kCGInterpolationHigh];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(queue, ^{
                        mediaItem.mediaThumbImage = [fullSizeImage thumbnailImage:MRSLUserProfileImageThumbDimensionSize
                                                             interpolationQuality:kCGInterpolationHigh];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            dispatch_async(queue, ^{
                                [mediaItem processMediaToDataWithSuccess:^(NSData *fullImageData, NSData *largeImageData, NSData *thumbImageData) {
                                    if (weakSelf) {
                                        dispatch_async(main, ^{
                                            weakSelf.user.profilePhotoFull = fullImageData;
                                            weakSelf.user.profilePhotoLarge = largeImageData;
                                            weakSelf.user.profilePhotoThumb = thumbImageData;
                                            [weakSelf.view hideActivityView];
                                            weakSelf.photoChanged = YES;
                                            [[weakSelf.navigationItem rightBarButtonItem] setEnabled:[self isDirty]];
                                        });
                                    }
                                }];
                            });
                        });
                    });
                });
            });
        });
    });
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
