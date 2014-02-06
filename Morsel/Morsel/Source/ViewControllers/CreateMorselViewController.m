//
//  CreateMorselViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "CreateMorselViewController.h"

#import "AddTextViewController.h"
#import "CaptureMediaViewController.h"
#import "CreateMorselButtonPanelView.h"
#import "GCPlaceholderTextView.h"
#import "JSONResponseSerializerWithData.h"
#import "UserPostsViewController.h"
#import "SocialService.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

#import <Accounts/Accounts.h>
#import <OAuthCore/OAuth+Additions.h>
#import <Social/Social.h>

NS_ENUM(NSUInteger, CreateMorselActionSheet) {
    CreateMorselActionSheetSettings = 1,
    CreateMorselActionSheetFacebookAccounts,
    CreateMorselActionSheetTwitterAccounts
};

@interface CreateMorselViewController ()
<AddTextViewControllerDelegate,
CaptureMediaViewControllerDelegate,
CreateMorselButtonPanelViewDelegate,
UIActionSheetDelegate,
UITextViewDelegate,
UserPostsViewControllerDelegate>

@property (nonatomic) BOOL wasDraft;
@property (nonatomic) BOOL saveDraft;
@property (nonatomic) BOOL willPublish;
@property (nonatomic) BOOL userIsEditing;
@property (nonatomic) BOOL imageUpdated;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *createTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *postMorselButton;
@property (weak, nonatomic) IBOutlet UIView *titleAlertView;
@property (weak, nonatomic) IBOutlet UITextField *postTitleField;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@property (weak, nonatomic) IBOutlet CreateMorselButtonPanelView *createMorselButtonPanelView;

@property (nonatomic, strong) NSString *temporaryPostTitle;

@property (nonatomic, strong) AddTextViewController *addTextViewController;
@property (nonatomic, strong) UserPostsViewController *userPostsViewController;
@property (nonatomic, strong) MRSLPost *post;
@property (nonatomic, strong) NSArray *twitterAccounts;
@property (nonatomic, strong) NSArray *facebookAccounts;

@end

@implementation CreateMorselViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.createMorselButtonPanelView.delegate = self;

#warning This is a temporary navigation solution and loads both subcontent views immediately.

    self.addTextViewController = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"AddTextViewController"];
    self.addTextViewController.delegate = self;

    self.userPostsViewController = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"UserPostsViewController"];
    self.userPostsViewController.delegate = self;

    CGRect subContentFrame = CGRectMake(0.f, 134.f, 320.f, 304.f);

    [_addTextViewController.view setFrame:subContentFrame];
    [_userPostsViewController.view setFrame:subContentFrame];

    [self addChildViewController:_addTextViewController];
    [self addChildViewController:_userPostsViewController];

    [self.view addSubview:_addTextViewController.view];
    [self.view addSubview:_userPostsViewController.view];

    _userPostsViewController.view.hidden = YES;

    if (!_thumbnailImageView.image) {
        [self renderThumbnail];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!_morsel.morselPhotoURL &&
        !_morsel.morselDescription) {
        // Entered through Morsel Creation

        self.createTitleLabel.text = @"Add Morsel";

        if (!_morsel) {
            MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:Appdelegate.defaultContext];

            self.morsel = morsel;
        }
    } else {
        // Entered through Edit Morsel. Setting states.

        self.createTitleLabel.text = @"Edit Morsel";

        self.userIsEditing = YES;

        if (!_post) {
            self.post = _morsel.post;

            if (_morsel.morselPhotoURL) {
                __weak __typeof(self) weakSelf = self;

                [_thumbnailImageView setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeThumbnail]
                                           placeholderImage:nil
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                 {
                     if (image) {
                         weakSelf.thumbnailImageView.image = image;
                     }
                 }
                                                    failure:
                 ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error)
                 {
                     DDLogError(@"Unable to set Morsel Thumbnail: %@", error.userInfo);
                 }];
            }

            self.addTextViewController.textView.text = _morsel.morselDescription;

            [self.postMorselButton setTitle:@"Save Changes"
                                   forState:UIControlStateNormal];
        }
    }

    self.wasDraft = _morsel.draftValue;

    if (_post) {
        self.userPostsViewController.post = _post;
        self.userPostsViewController.temporaryPostTitle = _temporaryPostTitle;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

- (void)setCapturedImage:(UIImage *)capturedImage {
    if (_capturedImage != capturedImage) {
        _capturedImage = capturedImage;

        [self renderThumbnail];
    }
}

#pragma mark - Private Methods

- (void)goBack {
    self.settingsButton.hidden = NO;
    self.doneButton.hidden = YES;

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goBackToCaptureMedia:(id)sender {
    if (!_userIsEditing) {
        [Appdelegate.defaultContext deleteObject:_morsel];

        if (_capturedImage) {
            self.thumbnailImageView.image = nil;
            self.capturedImage = nil;
        }
    }

    [self goBack];
}

- (IBAction)resignKeyboard {
    self.settingsButton.hidden = NO;
    self.doneButton.hidden = YES;

    [self.view endEditing:YES];
}

- (void)renderThumbnail {
    if (_capturedImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            UIImage *thumbnailImage = [_capturedImage thumbnailImage:70.f
                                                interpolationQuality:kCGInterpolationHigh];

            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               _thumbnailImageView.image = thumbnailImage;
                           });
        });
    }
}

- (IBAction)changeMedia {
    if (!_userIsEditing) {
        [self goBackToCaptureMedia:nil];

        return;
    }

    CaptureMediaViewController *captureMediaVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"CaptureMediaViewController"];
    captureMediaVC.morsel = _morsel;
    captureMediaVC.delegate = self;

    [self presentViewController:captureMediaVC
                       animated:YES
                     completion:nil];
}

- (void)showActionSheetWithAccountsForAccountTypeIdentifier:(NSString *)accountTypeIdentifier {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    NSArray *accounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier]];
    NSMutableArray *buttonTitles = [NSMutableArray array];
    NSUInteger actionSheetTag = 0;

    if ([accountTypeIdentifier isEqualToString:ACAccountTypeIdentifierFacebook]) {
        for (ACAccount *account in accounts) {
            NSString *fullName = [[account valueForKey:@"properties"] objectForKey:@"ACPropertyFullName"];
            if (fullName.length > 0) {
                [buttonTitles addObject:[NSString stringWithFormat:@"%@ (%@)", fullName, account.username]];
            } else {
                [buttonTitles addObject:account.username];
            }
        }
        _facebookAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
        actionSheetTag = CreateMorselActionSheetFacebookAccounts;
    } else {
        for (ACAccount *account in accounts) {
            [buttonTitles addObject:account.username];
        }
        _twitterAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
        actionSheetTag = CreateMorselActionSheetTwitterAccounts;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        //  show actionsheet with accounts and 'Cancel'
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];

        for (NSString *buttonTitle in buttonTitles) {
            [actionSheet addButtonWithTitle:buttonTitle];
        }

        [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
        [actionSheet setTag:actionSheetTag];
        [actionSheet showInView:self.view];
    });
}

- (IBAction)toggleFacebook:(UIButton *)button {
    MRSLUser *currentUser = [MRSLUser currentUser];
    if ([currentUser facebook_uid]) {
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            NSArray *facebookAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];

            if ([facebookAccounts count] == 0) {
                //  Request to grab the accounts
                SocialService *socialService = [[SocialService alloc] init];
                __weak typeof(self) weakSelf = self;
                [socialService requestReadAndWriteForFacebookAccountsWithBlock:^(BOOL granted, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
                }];
            } else {
                [self showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            }
        } else {
            [UIAlertView showAlertViewWithTitle:@"Error"
                                        message:@"No Facebook Account found on this device."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        }
    }
}

- (IBAction)toggleTwitter:(UIButton *)button {
    MRSLUser *currentUser = [MRSLUser currentUser];

    if ([currentUser twitter_username]) {
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            //  Get a list of their Twitter accounts
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];

            if ([twitterAccounts count] == 0) {
                //  Request to grab the accounts
                SocialService *socialService = [[SocialService alloc] init];
                __weak typeof(self) weakSelf = self;
                [socialService requestReadAndWriteForTwitterAccountsWithBlock:^(BOOL granted, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                }];
            } else {
                [self showActionSheetWithAccountsForAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            }
        } else {
            //      show alert saying no twitter accounts found on device
            [UIAlertView showAlertViewWithTitle:@"Error"
                                        message:@"No Twitter Accounts found on this device."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        }
    }
}

- (IBAction)postMorsel {
    if (!self.addTextViewController.textView.text && !_capturedImage) {
        [UIAlertView showAlertViewWithTitle:@"Post Error"
                                    message:@"Please add content to the Morsel."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        return;
    }

    if (_userIsEditing) {
        [self updateMorsel];
        return;
    }

    if (_saveDraft) {
        [self saveAsDraft];
    } else {
        [self publishMorsel];
    }
}

- (void)updateMorsel {
    int originalPostID = [_morsel.post.postID intValue];
    int potentialPostID = [_post.postID intValue];

    if (originalPostID != potentialPostID) {
        DDLogDebug(@"Post Association for Morsel Changed from Post %i to Post %i!", originalPostID, potentialPostID);

        if (self.temporaryPostTitle) {
            _post.title = _temporaryPostTitle;
        }

        _morsel.post = _post;
    }

    if (_willPublish) {
        _morsel.draft = @NO;
    }

    if (self.addTextViewController.textView.text)
        _morsel.morselDescription = self.addTextViewController.textView.text;

    if (_imageUpdated)
        [self addMediaDataToCurrentMorsel];

    __weak __typeof(self) weakSelf = self;

    [Appdelegate.morselApiService updateMorsel:_morsel
                                       success:^(id responseObject)
     {

         if (weakSelf) {
             [weakSelf goBack];
         }
     } failure: ^(NSError * error) {
         [UIAlertView showAlertViewWithTitle:@"Oops, something went wrong"
                                     message:@"Unable to update Morsel!"
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
     }];
}

- (void)saveAsDraft {
    if (_morsel) {
        if (!self.post) {
            // Creating a temporary post

            MRSLPost *post = [MRSLPost MR_createInContext:Appdelegate.defaultContext];
            post.postID = nil;
            post.creator = [MRSLUser currentUser];

            if (self.temporaryPostTitle) {
                post.title = _temporaryPostTitle;
            }

            _morsel.post = post;
        } else {
            // Adding Draft Morsel to existing Post!

            if (self.temporaryPostTitle) {
                _post.title = _temporaryPostTitle;
            }

            _morsel.post = _post;
        }

        if (self.addTextViewController.textView.text)
            _morsel.morselDescription = self.addTextViewController.textView.text;

        _morsel.draft = @YES;
    }

    [self prepareMediaAndPostMorsel];
}

- (void)publishMorsel {
    if (self.post) {
        if (self.temporaryPostTitle) {
            _post.title = _temporaryPostTitle;
        }

        _post.creator = [MRSLUser currentUser];

        _morsel.post = _post;
    }

    if (self.addTextViewController.textView.text)
        _morsel.morselDescription = self.addTextViewController.textView.text;

    [self prepareMediaAndPostMorsel];
}

- (void)prepareMediaAndPostMorsel {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addMediaDataToCurrentMorsel];

        [Appdelegate.morselApiService createMorsel:_morsel
                                    postToFacebook:_facebookButton.selected
                                     postToTwitter:_twitterButton.selected
                                           success:nil
                                           failure:^(NSError *error)
         {
             NSDictionary *errorDictionary = error.userInfo[JSONResponseSerializerWithDataKey];
             NSString *errorString = [NSString stringWithFormat:@"%@ Morsel Error: %@", _morsel.draft ? @"Draft" : @"Publish", errorDictionary[@"errors"]];

             [UIAlertView showAlertViewWithTitle:@"Oops, error publishing Morsel."
                                         message:errorString
                                        delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];

             DDLogError(@"Error! Unable to create Morsel: %@", errorString);
         }];
    });

    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)displaySettings {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Settings"
                                                             delegate:self
                                                    cancelButtonTitle:_userIsEditing ? @"Cancel" : nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];

    if (!_userIsEditing) {
        NSArray *buttonTitles = @[@"Publish Now", @"Save Draft"];
        for (NSString *buttonTitle in buttonTitles) {
            [actionSheet addButtonWithTitle:buttonTitle];
        }
    } else if (_wasDraft) {
        [actionSheet addButtonWithTitle:(!_willPublish) ? @"Publish Morsel" : @"Keep as Draft"];
        [actionSheet addButtonWithTitle:@"Delete Morsel"];
    }

    [actionSheet setTag:CreateMorselActionSheetSettings];
    [actionSheet showInView:self.view];
}

#pragma mark - Image Processing Methods

- (void)addMediaDataToCurrentMorsel {
    if (!_capturedImage) return;

    BOOL imageIsLandscape = [Util imageIsLandscape:_capturedImage];
    CGFloat cameraDimensionScale = [Util cameraDimensionScaleFromImage:_capturedImage];
    CGFloat cropStartingY = yCameraImagePreviewOffset * cameraDimensionScale;
    CGFloat minimumImageDimension = (imageIsLandscape) ? _capturedImage.size.height : _capturedImage.size.width;
    CGFloat maximumImageDimension = (imageIsLandscape) ? _capturedImage.size.width : _capturedImage.size.height;
    CGFloat xCenterAdjustment = (maximumImageDimension - minimumImageDimension) / 2.f;

    UIImage *processedImage = [_capturedImage croppedImage:CGRectMake((imageIsLandscape) ? xCenterAdjustment : 0.f, (imageIsLandscape) ? 0.f : cropStartingY, minimumImageDimension, minimumImageDimension)
                                                    scaled:CGSizeZero];

    _morsel.morselPhoto = UIImageJPEGRepresentation(processedImage, 1.f);
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == CreateMorselActionSheetSettings) {
        if (_userIsEditing) {
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Morsel"]) {
                [Appdelegate.morselApiService deleteMorsel:_morsel
                                                   success:^(BOOL success) {
                                                       [self goBack];
                                                   } failure: ^(NSError * error) {
                                                       [UIAlertView showAlertViewWithTitle:@"Oops, something went wrong."
                                                                                   message:@"Unable to delete Morsel!"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                                   }];
            }
            if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
                self.willPublish = ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Publish Morsel"]);
            }
        } else {
            self.saveDraft = ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save Draft"]);

            [self.postMorselButton setTitle:_saveDraft ? @"Save Morsel" : @"Publish Morsel"
                                   forState:UIControlStateNormal];
        }
    } else if (actionSheet.tag == CreateMorselActionSheetFacebookAccounts) {
        if (buttonIndex == [_facebookAccounts count]) return;
        SocialService *socialService = [[SocialService alloc] init];
        __weak typeof(self) weakSelf = self;
        [socialService requestReadAndWriteForFacebookAccountsWithBlock:^(BOOL granted, NSError *error) {
            if (error) {
                [UIAlertView showAlertViewForError:error
                                          delegate:nil];
            } else {
                ACAccountStore *accountStore = [[ACAccountStore alloc] init];
                //  Get _facebookAccounts again after access has been granted, otherwise the account's credential will be nil
                _facebookAccounts = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
                ACAccount *selectedAccount = _facebookAccounts[buttonIndex];
                [[Appdelegate morselApiService] createFacebookAuthorizationWithToken:[[selectedAccount credential] oauthToken]
                                                                             forUser:[MRSLUser currentUser]
                                                                             success:^(id responseObject) {
                                                                                 [Appdelegate.morselApiService updateUser:[MRSLUser currentUser] success:^(id userResponseObject) {
                                                                                     __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                     [strongSelf->_facebookButton setEnabled:YES];
                                                                                     [strongSelf->_facebookButton setSelected:!strongSelf->_facebookButton.selected];
                                                                                 } failure:^(NSError *error) {
                                                                                     __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                     [strongSelf->_facebookButton setEnabled:YES];
                                                                                     [UIAlertView showAlertViewForError:error
                                                                                                               delegate:nil];
                                                                                 }];
                                                                             } failure:^(NSError *error) {
                                                                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                 [strongSelf->_facebookButton setEnabled:YES];
                                                                                 [UIAlertView showAlertViewForError:error
                                                                                                           delegate:nil];
                                                                             }];
            }
        }];
    } else if (actionSheet.tag == CreateMorselActionSheetTwitterAccounts) {
        if (buttonIndex == [_twitterAccounts count]) return;
        ACAccount *selectedAccount = _twitterAccounts[buttonIndex];
        SocialService *socialService = [[SocialService alloc] init];
        [_twitterButton setEnabled:NO];

        [socialService performReverseAuthForTwitterAccount:selectedAccount
                                                 withBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     NSDictionary *params = [NSURL ab_parseURLQueryString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                                                     __weak typeof(self) weakSelf = self;
                                                     [Appdelegate.morselApiService createTwitterAuthorizationWithToken:params[@"oauth_token"]
                                                                                                                secret:params[@"oauth_token_secret"]
                                                                                                               forUser:[MRSLUser currentUser]
                                                                                                               success:^(id responseObject) {
                                                                                                                   [Appdelegate.morselApiService updateUser:[MRSLUser currentUser] success:^(id userResponseObject) {
                                                                                                                       __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                       [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                       [strongSelf->_twitterButton setSelected:!strongSelf->_twitterButton.selected];
                                                                                                                   } failure:^(NSError *error) {
                                                                                                                       __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                       [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                       [UIAlertView showAlertViewForError:error
                                                                                                                                                 delegate:nil];
                                                                                                                   }];
                                                                                                               } failure:^(NSError *error) {
                                                                                                                   __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                   [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                   [UIAlertView showAlertViewForError:error
                                                                                                                                             delegate:nil];
                                                                                                               }];
                                                 }];
    }
}

#pragma mark - AddTextViewControllerDelegate Methods

- (void)addTextViewDidBeginEditing {
    self.settingsButton.hidden = YES;
    self.doneButton.hidden = NO;
}

#pragma mark - CaptureMediaViewControllerDelegate Methods

- (void)captureMediaViewControllerDidAcceptImage:(UIImage *)updatedImage {
    self.capturedImage = updatedImage;
    self.imageUpdated = YES;
}

#pragma mark - CreateMorselButtonPanelViewDelegate Methods

- (void)createMorselButtonPanelDidSelectAddText {
    self.addTextViewController.view.hidden = NO;
    self.userPostsViewController.view.hidden = YES;
}

- (void)createMorselButtonPanelDidSelectAddProgression {
    self.addTextViewController.view.hidden = YES;
    self.userPostsViewController.view.hidden = NO;
}

#pragma mark - UserPostsViewControllerDelegate Methods

- (void)userPostsSelectedPost:(MRSLPost *)post {
    self.temporaryPostTitle = nil;
    self.post = post;

    if (_post && !_post.title) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view bringSubviewToFront:_titleAlertView];

            self.titleAlertView.hidden = NO;
            [self.postTitleField becomeFirstResponder];
        });
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.temporaryPostTitle = textField.text;

        textField.text = @"";

        self.userPostsViewController.temporaryPostTitle = _temporaryPostTitle;

        self.titleAlertView.hidden = YES;
        [textField resignFirstResponder];

        return YES;
    }
    return NO;
}

@end
