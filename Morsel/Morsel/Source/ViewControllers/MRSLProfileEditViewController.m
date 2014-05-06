//
//  MRSLProfileEditViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/22/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileEditViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "MRSLKeywordUsersViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLProfileStatsTagsViewController.h"
#import "MRSLUserTagEditViewController.h"

#import "MRSLTag.h"
#import "MRSLUser.h"

@interface MRSLProfileEditViewController ()
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate,
UITextViewDelegate,
MRSLProfileStatsTagsViewControllerDelegate>

@property (nonatomic) CGFloat scrollViewContentHeight;

@property (strong, nonatomic) NSString *keywordType;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *bioTextView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) IBOutletCollection(NSObject) NSArray *requiredFields;

@end

@implementation MRSLProfileEditViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    MRSLProfileStatsTagsViewController *profileStatsKeywordsVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileStatsKeywordsViewController"];
    profileStatsKeywordsVC.allowsEdit = YES;
    profileStatsKeywordsVC.user = _user;
    [profileStatsKeywordsVC.view setY:[_bioTextView getHeight] + [_bioTextView getY] + 8.f];
    [profileStatsKeywordsVC.view setHeight:214.f];
    [profileStatsKeywordsVC.view setBackgroundColor:self.view.backgroundColor];
    profileStatsKeywordsVC.delegate = self;
    [self addChildViewController:profileStatsKeywordsVC];
    [self.scrollView addSubview:profileStatsKeywordsVC.view];

    [_logoutButton setY:[profileStatsKeywordsVC.view getHeight] + [profileStatsKeywordsVC.view getY] + 8.f];

    self.scrollViewContentHeight = [_logoutButton getHeight] + [_logoutButton getY] + 20.f;
    _bioTextView.placeholder = @"Biography";
    self.scrollView.contentSize = CGSizeMake([self.view getWidth], _scrollViewContentHeight);

    [self populateContent];
}

- (void)setUser:(MRSLUser *)user {
    if (_user != user) {
        _user = user;
        [self populateContent];
    }
}

#pragma mark - Private Methods

- (void)populateContent {
    self.profileImageView.user = _user;
    self.usernameLabel.text = _user.username;
    self.firstNameField.text = _user.first_name;
    self.lastNameField.text = _user.last_name;
    self.emailField.text = _user.email;
    self.bioTextView.text = _user.bio;
}

- (void)focusScrollViewToFrame:(CGRect)frame {
    frame.origin.y = frame.origin.y - ([_scrollView getHeight] / 2);
    [_scrollView scrollRectToVisible:frame
                            animated:YES];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_EditKeywords"]) {
        MRSLUserTagEditViewController *userTagEditVC = [segue destinationViewController];
        userTagEditVC.keywordType = _keywordType;
    }
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.scrollView setHeight:[self.view getHeight] - keyboardSize.height];
                     }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.scrollView setHeight:[self.view getHeight]];
                     }];
}

#pragma mark - Action Methods

- (IBAction)logout {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceShouldLogOutUserNotification
                                                        object:nil];
}

- (IBAction)updateProfile {
    BOOL fieldsFilled = YES;
    for (NSObject *requiredField in _requiredFields) {
        if ([requiredField respondsToSelector:@selector(text)]) {
            if ([[(UITextField *)requiredField text] length] == 0) {
                [(UIView *)requiredField setBorderWithColor:[UIColor morselRed]
                                                   andWidth:2.f];
                fieldsFilled = NO;
            } else {
                [(UIView *)requiredField setBorderWithColor:nil
                                                   andWidth:0.f];
            }
        }
    }
    if (!fieldsFilled) {
        [UIAlertView showAlertViewForErrorString:@"Please fill in all fields."
                                        delegate:nil];
        return;
    }

    BOOL userDidUpdate = (_user.first_name) ? ![_user.first_name isEqualToString:_firstNameField.text] : (![_firstNameField.text length] == 0);
    userDidUpdate = (_user.last_name) ? ![_user.last_name isEqualToString:_lastNameField.text] : (![_lastNameField.text length] == 0);
    userDidUpdate = (_user.email) ? ![_user.email isEqualToString:_emailField.text] : (![_emailField.text length] == 0);
    userDidUpdate = (_user.bio) ? ![_user.bio isEqualToString:_bioTextView.text] : (![_bioTextView.text length] == 0);

    if (userDidUpdate) {
        _user.first_name = _firstNameField.text;
        _user.last_name = _lastNameField.text;
        _user.email = _emailField.text;
        _user.bio = _bioTextView.text;

        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService updateUser:_user
                                    success:^(id responseObject) {
                                        [weakSelf goBack];
                                    } failure:nil];
    } else {
        [self goBack];
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

    [profileActionSheet showInView:self.view];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self focusScrollViewToFrame:textField.frame];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self focusScrollViewToFrame:textView.frame];
}

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
        [self.profileImageView addAndRenderImage:originalProfileImage];
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

#pragma mark - MRSLProfileStatsKeywordsViewControllerDelegate Methods

- (void)profileStatsTagsViewControllerDidSelectTag:(MRSLTag *)tag {
    MRSLKeywordUsersViewController *keywordUsersVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLKeywordUsersViewController"];
    keywordUsersVC.keyword = tag.keyword;
    [self.navigationController pushViewController:keywordUsersVC
                                         animated:YES];
}

- (void)profileStatsTagsViewControllerDidSelectType:(NSString *)type {
    self.keywordType = type;
    [self performSegueWithIdentifier:@"seg_EditKeywords"
                              sender:nil];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
