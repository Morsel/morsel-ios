//
//  SignUpViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSignUpViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "MRSLAPIService+Registration.h"

#import "MRSLCheckbox.h"
#import "MRSLLightButton.h"
#import "MRSLProfileImageView.h"
#import "MRSLValidationStatusView.h"

#import "MRSLSocialUser.h"
#import "MRSLUser.h"

@interface MRSLSignUpViewController ()
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate>

@property (nonatomic) BOOL userConnectedWithSocial;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet MRSLValidationStatusView *usernameStatusView;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet MRSLCheckbox *proCheckbox;

@property (strong, nonatomic) MRSLSocialAuthentication *socialAuthentication;

@property (strong, nonatomic) UIImage *originalProfileImage;

@end

@implementation MRSLSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"sign_up";

    if (_socialUser) {
        self.userConnectedWithSocial = YES;

        self.socialAuthentication = _socialUser.authentication;

        self.firstNameField.text = _socialUser.firstName;
        self.lastNameField.text = _socialUser.lastName;
        if (!_shouldOmitEmail) self.emailField.text = _socialUser.email;
        self.passwordField.hidden = YES;

        dispatch_queue_t queue = dispatch_queue_create("com.eatmorsel.social-image-processing", NULL);
        dispatch_queue_t main = dispatch_get_main_queue();

        self.addPhotoButton.enabled = NO;
        __weak __typeof(self) weakSelf = self;
        dispatch_async(queue, ^{
            weakSelf.originalProfileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:_socialUser.pictureURL]];
            dispatch_async(main, ^{
                [weakSelf.profileImageView addAndRenderImage:weakSelf.originalProfileImage
                                                    complete:^(BOOL success) {
                                                        weakSelf.addPhotoButton.enabled = YES;
                                                        if (success) {
                                                            [weakSelf.addPhotoButton setTitle:@"Edit"
                                                                                     forState:UIControlStateNormal];
                                                        } else {
                                                            weakSelf.originalProfileImage = nil;
                                                        }
                                                    }];

            });
        });
    }

    [self.firstNameField addDefaultBorderForDirections:MRSLBorderWest];
    [self.lastNameField addDefaultBorderForDirections:MRSLBorderWest];

    [self.proCheckbox.titleLabel setText:@"I am a professional chef, sommelier, mixologist, etc."];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    [super viewWillAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Private Methods

- (IBAction)displayTermsOfService {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Terms of Service",
                                                                                                                   @"url": [NSURL URLWithString:[NSString stringWithFormat:@"%@/terms_text", MORSEL_BASE_URL]]}];
}

- (IBAction)displayPrivacyPolicy {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Privacy Policy",
                                                                                                                   @"url": [NSURL URLWithString:[NSString stringWithFormat:@"%@/privacy_text", MORSEL_BASE_URL]]}];
}


- (IBAction)addPhoto:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Add Photo Icon",
                                              @"_view": self.mp_eventView}];

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
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Get started",
                                              @"_view": self.mp_eventView,
                                              @"incl_profile_image": (self.originalProfileImage) ? @"true" : @"false",
                                              @"pro_checkbox": ([self.proCheckbox isChecked]) ? @"true" : @"false"}];

    BOOL usernameValid = [MRSLUtil validateUsername:_usernameField.text];
    BOOL emailValid = [MRSLUtil validateEmail:_emailField.text];
    BOOL passValid = ([_passwordField.text length] >= 8) || _userConnectedWithSocial;

    if (!usernameValid || !emailValid || !passValid) {
        [UIAlertView showAlertViewWithTitle:_userConnectedWithSocial ? @"Invalid username or email" : @"Invalid username, email, or password"
                                    message:_userConnectedWithSocial ? @"Username and email must be valid." : @"Username and email must be valid. Password must be at least 8 characters."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
        return;
    }

    if ([_usernameField.text length] == 0 ||
        ([_passwordField.text length] == 0 && !_userConnectedWithSocial) ||
        [_emailField.text length] == 0 ||
        [_firstNameField.text length] == 0 ||
        [_lastNameField.text length] == 0 ||
        !_profileImageView.image) {
        [UIAlertView showAlertViewWithTitle:@"All Fields Required"
                                    message:@"Please fill in all fields and include a profile picture."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil];
        return;
    }

    [_continueButton setEnabled:NO];

    [self.view showActivityViewWithMode:RNActivityViewModeIndeterminate
                                  label:@"Signing up"
                            detailLabel:nil];

    MRSLUser *user = [MRSLUser MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    user.first_name = _firstNameField.text;
    user.last_name = _lastNameField.text;
    user.username = _usernameField.text;
    user.email = _emailField.text;
    user.professional = @(_proCheckbox.checkState);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *profileImageFull = [_originalProfileImage thumbnailImage:_originalProfileImage.size.width
                                                     interpolationQuality:kCGInterpolationHigh];
        UIImage *profileImageLarge = [profileImageFull thumbnailImage:MRSLUserProfileImageLargeDimensionSize
                                                 interpolationQuality:kCGInterpolationHigh];
        UIImage *profileImageThumb = [profileImageFull thumbnailImage:MRSLUserProfileImageThumbDimensionSize
                                                 interpolationQuality:kCGInterpolationHigh];
        user.profilePhotoLarge = UIImageJPEGRepresentation(profileImageLarge, 1.f);
        user.profilePhotoThumb = UIImageJPEGRepresentation(profileImageThumb, 1.f);

        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            user.profilePhotoFull = UIImageJPEGRepresentation(profileImageFull, 1.f);

            [_appDelegate.apiService createUser:user
                                   withPassword:_userConnectedWithSocial ? nil : _passwordField.text
                              andAuthentication:_socialAuthentication
                                        success:^(id responseObject) {
                                            MRSLUser *newUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                        withValue:responseObject[@"id"]];
                                            if (newUser.presignedUpload && newUser.profilePhotoFull) {
                                                [newUser API_updateImage];
                                            }

                                            [[Mixpanel sharedInstance] createAlias:[responseObject[@"id"] stringValue]
                                                                     forDistinctID:[Mixpanel sharedInstance].distinctId];
                                            [[MRSLEventManager sharedManager] track:@"$signup"];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                                                    object:nil];

                                                if ([weakSelf.proCheckbox checkState]) {
                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayProfessionalSettingsNotification
                                                                                                            object:nil];
                                                    });
                                                } else {
                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayOnboardingNotification object:nil];
                                                    });
                                                }
                                            });
                                        } failure:^(NSError *error) {
                                            [weakSelf.view hideActivityView];
                                            [weakSelf.continueButton setEnabled:YES];

                                            MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

                                            [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                             delegate:nil];
                                        }];
        });

        self.originalProfileImage = nil;
    });
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) return;

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Take Photo",
                                                  @"_view": self.mp_eventView}];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Select From Library",
                                                  @"_view": self.mp_eventView}];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    imagePicker.delegate = self;

    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (void)beginSignUpAndResign {
    [self.view endEditing:YES];
    [self signUp];
    [self.contentScrollView scrollRectToVisible:CGRectMake(0.f, 0.f, 5.f, 5.f)
                                       animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        [[MRSLEventManager sharedManager] track:@"Added Photo"
                                     properties:@{@"_view": self.mp_eventView}];

        self.originalProfileImage = info[UIImagePickerControllerEditedImage];

        [self.profileImageView addAndRenderImage:_originalProfileImage
                                        complete:nil];

        [self.addPhotoButton setTitle:@"Edit"
                             forState:UIControlStateNormal];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Cancel",
                                              @"_view": self.mp_eventView}];
    [self dismissViewControllerAnimated:YES
                             completion:nil];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];

    if ([textField isEqual:_usernameField]) {
        self.usernameStatusView.hidden = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    if ([textField isEqual:_usernameField]) {
        if ([_usernameField.text length] > 0) {
            __weak __typeof(self)weakSelf = self;
            _usernameStatusView.hidden = NO;
            _usernameStatusView.statusLabel.hidden = NO;
            _usernameStatusView.statusLabel.text = @"Checking";
            _usernameStatusView.statusLabel.textColor = [UIColor morselValidColor];
            [_usernameStatusView.activityIndicator startAnimating];
            [_appDelegate.apiService checkUsernameAvailability:_usernameField.text
                                                     validated:^(BOOL isAvailable, NSError *error) {
                                                         if (isAvailable && !error) {
                                                             weakSelf.usernameStatusView.statusLabel.text = @"Available";
                                                             weakSelf.usernameStatusView.statusLabel.textColor = [UIColor morselValidColor];
                                                         } else if (isAvailable && error) {
                                                             weakSelf.usernameStatusView.statusLabel.text = @"Invalid";
                                                             weakSelf.usernameStatusView.statusLabel.textColor = [UIColor morselInvalidColor];
                                                         } else {
                                                             weakSelf.usernameStatusView.statusLabel.text = @"Unavailable";
                                                             weakSelf.usernameStatusView.statusLabel.textColor = [UIColor morselInvalidColor];
                                                         }
                                                         [weakSelf.usernameStatusView.activityIndicator stopAnimating];
                                                         weakSelf.usernameStatusView.statusLabel.hidden = NO;
                                                     }];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        if ([textField isEqual:_firstNameField]) {
            [_lastNameField becomeFirstResponder];
        } else if ([textField isEqual:_lastNameField]) {
            [_usernameField becomeFirstResponder];
        } else if ([textField isEqual:_usernameField]) {
            [_emailField becomeFirstResponder];
        } else if ([textField isEqual:_emailField]) {
            if (_userConnectedWithSocial) {
                [self beginSignUpAndResign];
            } else {
                [_passwordField becomeFirstResponder];
            }
        } else if ([textField isEqual:_passwordField]) {
            [self beginSignUpAndResign];
        }

        return NO;
    } else {
        CGRect centeredFrame = textField.frame;
        centeredFrame.origin.y = textField.frame.origin.y - (self.contentScrollView.frame.size.height / 2);

        [self.contentScrollView scrollRectToVisible:centeredFrame
                                           animated:YES];
        if ([textField isEqual:_usernameField]) {
            NSUInteger textLength = (textField.text.length - range.length) + string.length;
            if (textLength > 15) {
                return NO;
            }
        }
        return YES;
    }
}

@end
