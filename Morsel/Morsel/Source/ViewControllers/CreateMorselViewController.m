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

static const CGFloat MRSLSubContentHeight = 304.f;
static const CGFloat MRSLSubContentHeightExpanded = 380.f;

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
UserPostsViewControllerDelegate,
UIDocumentInteractionControllerDelegate>

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
@property (weak, nonatomic) IBOutlet UIView *socialButtonsView;
@property (weak, nonatomic) IBOutlet UIView *titleAlertView;
@property (weak, nonatomic) IBOutlet UITextField *postTitleField;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;

@property (weak, nonatomic) IBOutlet CreateMorselButtonPanelView *createMorselButtonPanelView;

@property (nonatomic, strong) NSString *temporaryPostTitle;

@property (nonatomic, strong) AddTextViewController *addTextViewController;
@property (nonatomic, strong) UserPostsViewController *userPostsViewController;
@property (nonatomic, strong) MRSLPost *post;
@property (nonatomic, strong) NSArray *twitterAccounts;
@property (nonatomic, strong) NSArray *facebookAccounts;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation CreateMorselViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

#if (defined(MORSEL_BETA))
    self.socialButtonsView.hidden = YES;
#endif

    self.createMorselButtonPanelView.delegate = self;

    // This is a temporary navigation solution and loads both subcontent views immediately.

    self.addTextViewController = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_AddTextViewController"];
    self.addTextViewController.delegate = self;

    self.userPostsViewController = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_UserPostsViewController"];
    self.userPostsViewController.delegate = self;

    CGRect subContentFrame = CGRectMake(0.f, 134.f, 320.f, MRSLSubContentHeight);

    [_addTextViewController.view setFrame:subContentFrame];
    [_userPostsViewController.view setFrame:subContentFrame];

    [self addChildViewController:_addTextViewController];
    [self addChildViewController:_userPostsViewController];

    [self.view addSubview:_addTextViewController.view];
    [self.view addSubview:_userPostsViewController.view];

    [self.view bringSubviewToFront:_socialButtonsView];
    [self.view bringSubviewToFront:_postMorselButton];

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
            MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            morsel.isUploading = @YES;
            morsel.didFailUpload = @NO;

            self.morsel = morsel;
        }
    } else {
        // Entered through Edit Morsel. Setting states.

        self.wasDraft = _morsel.draftValue;

        self.createTitleLabel.text = _wasDraft ? @"Edit Draft" : @"Edit Morsel";

        [self shouldHideSocialView:_wasDraft];

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

    if (_post) {
        self.userPostsViewController.post = _post;
        self.userPostsViewController.temporaryPostTitle = _temporaryPostTitle;
    }

    if (_morsel) {
        self.userPostsViewController.morsel = _morsel;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

#pragma mark - Private Methods

- (void)goBack {
    [[MRSLEventManager sharedManager] track:@"Tapped Go Back"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    self.settingsButton.hidden = NO;
    self.doneButton.hidden = YES;

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goBackToCaptureMedia:(id)sender {
    if (!_userIsEditing) {
        [_morsel MR_deleteEntity];

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

- (IBAction)changeMedia {
    if (!_userIsEditing) {
        [self goBackToCaptureMedia:nil];

        return;
    }

    CaptureMediaViewController *captureMediaVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_CaptureMediaViewController"];
    captureMediaVC.morsel = _morsel;
    captureMediaVC.delegate = self;

    [self presentViewController:captureMediaVC
                       animated:YES
                     completion:nil];
}

- (IBAction)displaySettings {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Settings"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:(_wasDraft || _userIsEditing) ? @"Delete Morsel" : nil
                                                    otherButtonTitles:nil];

    if (!_userIsEditing) {
        NSArray *buttonTitles = @[@"Publish Now", @"Save Draft"];
        for (NSString *buttonTitle in buttonTitles) {
            [actionSheet addButtonWithTitle:buttonTitle];
        }
    } else if (_wasDraft) {
        [actionSheet addButtonWithTitle:(!_willPublish) ? @"Publish Morsel" : @"Keep as Draft"];
    }

    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
    [actionSheet setTag:CreateMorselActionSheetSettings];
    [actionSheet showInView:self.view];
}

- (IBAction)toggleFacebook:(UIButton *)button {
    MRSLUser *currentUser = [MRSLUser currentUser];

    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Facebook"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if ([currentUser facebook_uid]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Facebook"
                                     properties:@{@"view": @"CreateMorselViewController",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
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
            [UIAlertView showAlertViewForErrorString:@"Please add a Facebook Account to this device"
                                            delegate:nil];
        }
    }
}

- (IBAction)toggleInstagram:(UIButton *)button {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Instagram"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if ([button isSelected]) {
        [button setSelected:NO];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
        if (_capturedImage || _morsel.morselPhoto) {
            [button setSelected:YES];
        } else {
            [UIAlertView showAlertViewForErrorString:@"Please add a photo to post to Instagram"
                                            delegate:nil];
        }
    } else {
        [UIAlertView showAlertViewForErrorString:@"Please install Instagram to post your Morsel there"
                                        delegate:nil];
    }
}

- (IBAction)toggleTwitter:(UIButton *)button {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Twitter"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    MRSLUser *currentUser = [MRSLUser currentUser];

    if ([currentUser twitter_username]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Twitter"
                                     properties:@{@"view": @"CreateMorselViewController",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
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
            [UIAlertView showAlertViewForErrorString:@"Please add a Twitter Account to this device"
                                            delegate:nil];
        }
    }
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

- (void)shouldHideSocialView:(BOOL)shouldHide {
#if (defined(MORSEL_BETA))
    return;
#endif
    self.socialButtonsView.hidden = shouldHide;

    [self.addTextViewController.view setHeight:shouldHide ? MRSLSubContentHeightExpanded : MRSLSubContentHeight];
    [self.userPostsViewController.view setHeight:shouldHide ? MRSLSubContentHeightExpanded : MRSLSubContentHeight];

    [self.facebookButton setSelected:NO];
    [self.twitterButton setSelected:NO];
    [self.instagramButton setSelected:NO];
}

#pragma mark - Post Morsel

- (IBAction)postMorsel {
    if ([self.addTextViewController.textView.text length] == 0 && (!_capturedImage && !_thumbnailImageView.image)) {
        [UIAlertView showAlertViewForErrorString:@"Please add content to this Morsel"
                                        delegate:nil];
        return;
    }

    _postMorselButton.enabled = NO;

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
    [[MRSLEventManager sharedManager] track:@"Tapped Save Morsel"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"morsel_draft":(_morsel.draftValue) ? @"true" : @"false"}];

    if (_willPublish) {
        _morsel.draft = @NO;
    }

    if (self.addTextViewController.textView.text)
        _morsel.morselDescription = self.addTextViewController.textView.text;

    if (_imageUpdated)
        [self addMediaDataToCurrentMorsel];


    int originalPostID = [_morsel.post.postID intValue];
    int potentialPostID = [_post.postID intValue];

    if (originalPostID != potentialPostID) {
        DDLogDebug(@"Post Association for Morsel Changed from Post %i to Post %i!", originalPostID, potentialPostID);

        if (self.temporaryPostTitle) {
            _post.title = _temporaryPostTitle;
            [_appDelegate.morselApiService updatePost:_post
                                              success:nil
                                              failure:^(NSError *error) {
                                                  [UIAlertView showAlertViewForErrorString:@"Unable to Update Post Title"
                                                                                  delegate:nil];
                                              }];
        }
    }

    __weak __typeof(self) weakSelf = self;

    [_appDelegate.morselApiService updateMorsel:_morsel
                                        andPost:(originalPostID != potentialPostID) ? _post : nil
                                        success:^(id responseObject) {
                                            if (weakSelf) {
                                                [weakSelf goBack];
                                            }
                                        } failure: ^(NSError * error) {
                                            _postMorselButton.enabled = YES;
                                            [UIAlertView showAlertViewForErrorString:@"Unable to update Morsel"
                                                                            delegate:nil];
                                        }];
}

- (void)saveAsDraft {
    [[MRSLEventManager sharedManager] track:@"Tapped Save Morsel as Draft"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    if (_morsel) {
        if (self.post) {
            DDLogDebug(@"Adding Draft Morsel (%i) to existing Post (%i)!", _morsel.morselIDValue, _post.postIDValue);

            if (self.temporaryPostTitle) {
                _post.title = _temporaryPostTitle;
            }

            [_post addMorselsObject:_morsel];
            _morsel.post = _post;
        }

        if (self.addTextViewController.textView.text) _morsel.morselDescription = self.addTextViewController.textView.text;

        _morsel.creationDate = [NSDate date];
        _morsel.draft = @YES;
    }

    [[MRSLUser currentUser] incrementDraftCountAndSave];

    [self prepareMediaAndPostMorsel];
}

- (void)publishMorsel {
    [[MRSLEventManager sharedManager] track:@"Tapped Publish Morsel"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"morsel_draft":(_morsel.draftValue) ? @"true" : @"false"}];
    if (self.post) {
        DDLogDebug(@"Publishing Morsel (%i) to existing Post (%i)!", _morsel.morselIDValue, _post.postIDValue);

        if (self.temporaryPostTitle) {
            _post.title = _temporaryPostTitle;
        }

        [_post addMorselsObject:_morsel];
        _morsel.post = _post;
    }

    _morsel.creationDate = [NSDate date];
    _morsel.draft = @NO;

    if (self.addTextViewController.textView.text) _morsel.morselDescription = self.addTextViewController.textView.text;

    [self prepareMediaAndPostMorsel];
}

- (void)sendToInstagram {
    [[MRSLEventManager sharedManager] track:@"Presented Instagram Document Interaction Controller"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *photoFilePath = [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],@"tempinstgramphoto.igo"];
        [_morsel.morselPhoto writeToFile:photoFilePath atomically:YES];

        _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:photoFilePath]];
        _documentInteractionController.UTI = @"com.instagram.exclusivegram";
        _documentInteractionController.delegate = self;
        NSString *socialMessage = [_morsel socialMessage];
        if (socialMessage) {
            _documentInteractionController.annotation = [NSDictionary dictionaryWithObject:socialMessage
                                                                                    forKey:@"InstagramCaption"];
        }
        [_documentInteractionController presentOpenInMenuFromRect:CGRectZero
                                                           inView:self.view
                                                         animated:YES];
    });
}

- (void)prepareMediaAndPostMorsel {
    [self addMediaDataToCurrentMorsel];

    __weak typeof(self) weakSelf = self;

    [_appDelegate.morselApiService createMorsel:_morsel
                                 postToFacebook:_facebookButton.selected
                                  postToTwitter:_twitterButton.selected
                                        success:^(id responseObject) {
                                            __strong typeof(weakSelf) strongSelf = weakSelf;
                                            if (strongSelf) {
                                                if ([strongSelf->_instagramButton isSelected]) {
                                                    [strongSelf sendToInstagram];
                                                }
                                                strongSelf->_postMorselButton.enabled = YES;
                                            }
                                        }
                                        failure:^(NSError *error)
     {
         _postMorselButton.enabled = YES;
         [UIAlertView showAlertViewForServiceError:error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey]
                                          delegate:nil];
     }];

    if (!self.instagramButton.selected) {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
}

#pragma mark - Image Processing Methods

- (void)setCapturedImage:(UIImage *)capturedImage {
    if (_capturedImage != capturedImage) {
        _capturedImage = capturedImage;

        [self renderThumbnail];
    }
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

- (void)addMediaDataToCurrentMorsel {
    if (!_capturedImage) return;

    _morsel.morselThumb = UIImageJPEGRepresentation([_capturedImage thumbnailImage:30.f
                                                              interpolationQuality:kCGInterpolationHigh], .8f);

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
                [[MRSLEventManager sharedManager] track:@"Tapped Delete Morsel"
                                             properties:@{@"view": @"CreateMorselViewController",
                                                          @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                [_appDelegate.morselApiService deleteMorsel:_morsel
                                                    success:^(BOOL success) {
                                                        [self goBack];
                                                    } failure: ^(NSError * error) {
                                                        [UIAlertView showAlertViewForErrorString:@"Unable to delete Morsel"
                                                                                        delegate:nil];
                                                    }];
            }
            if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
                self.willPublish = ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Publish Morsel"]);

                [self.postMorselButton setTitle:_willPublish ? @"Publish" : @"Save Changes"
                                       forState:UIControlStateNormal];

                [self shouldHideSocialView:!_willPublish];
            }
        } else {
            self.saveDraft = ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save Draft"]);

            [self shouldHideSocialView:_saveDraft];

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
                [_appDelegate.morselApiService createFacebookAuthorizationWithToken:[[selectedAccount credential] oauthToken]
                                                                            forUser:[MRSLUser currentUser]
                                                                            success:^(id responseObject) {
                                                                                [_appDelegate.morselApiService updateUser:[MRSLUser currentUser] success:^(id userResponseObject) {
                                                                                    [[MRSLEventManager sharedManager] track:@"User Authorized with Facebook"
                                                                                                                 properties:@{@"view": @"CreateMorselViewController",
                                                                                                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                    [strongSelf->_facebookButton setEnabled:YES];
                                                                                    [strongSelf->_facebookButton setSelected:!strongSelf->_facebookButton.selected];
                                                                                } failure:^(NSError *error) {
                                                                                    [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Facebook"
                                                                                                                 properties:@{@"view": @"CreateMorselViewController",
                                                                                                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                    [strongSelf->_facebookButton setEnabled:YES];
                                                                                    [UIAlertView showAlertViewForError:error
                                                                                                              delegate:nil];
                                                                                }];
                                                                            } failure:^(NSError *error) {
                                                                                [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Facebook"
                                                                                                             properties:@{@"view": @"CreateMorselViewController",
                                                                                                                          @"morsel_id": NSNullIfNil(_morsel.morselID)}];
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
                                                     [_appDelegate.morselApiService createTwitterAuthorizationWithToken:params[@"oauth_token"]
                                                                                                                 secret:params[@"oauth_token_secret"]
                                                                                                                forUser:[MRSLUser currentUser]
                                                                                                                success:^(id responseObject) {
                                                                                                                    [_appDelegate.morselApiService updateUser:[MRSLUser currentUser] success:^(id userResponseObject) {
                                                                                                                        [[MRSLEventManager sharedManager] track:@"User Authorized with Twitter"
                                                                                                                                                     properties:@{@"view": @"CreateMorselViewController",
                                                                                                                                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                                                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                        [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                        [strongSelf->_twitterButton setSelected:!strongSelf->_twitterButton.selected];
                                                                                                                    } failure:^(NSError *error) {
                                                                                                                        [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Twitter"
                                                                                                                                                     properties:@{@"view": @"CreateMorselViewController",
                                                                                                                                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                                                                                                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                                                                        [strongSelf->_twitterButton setEnabled:YES];
                                                                                                                        [UIAlertView showAlertViewForError:error
                                                                                                                                                  delegate:nil];
                                                                                                                    }];
                                                                                                                } failure:^(NSError *error) {
                                                                                                                    [[MRSLEventManager sharedManager] track:@"User Unable to Authorize with Twitter"
                                                                                                                                                 properties:@{@"view": @"CreateMorselViewController",
                                                                                                                                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
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
    [[MRSLEventManager sharedManager] track:@"Tapped Add Text to Morsel"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    self.addTextViewController.view.hidden = NO;
    self.userPostsViewController.view.hidden = YES;
}

- (void)createMorselButtonPanelDidSelectAddProgression {
    [[MRSLEventManager sharedManager] track:@"Tapped Associate Morsel with Progression Icon"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    [self.view endEditing:YES];
    self.userPostsViewController.morsel = _morsel;
    self.addTextViewController.view.hidden = YES;
    self.userPostsViewController.view.hidden = NO;
}

#pragma mark - UserPostsViewControllerDelegate Methods

- (void)userPostsSelectedPost:(MRSLPost *)post {
    self.temporaryPostTitle = nil;
    self.post = post;

    [[MRSLEventManager sharedManager] track:@"Tapped Associate Morsel to Progression"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"post_id": NSNullIfNil(_post.postID)}];

    if (_post && !_post.title) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view bringSubviewToFront:_titleAlertView];

            self.titleAlertView.hidden = NO;
            [self.postTitleField becomeFirstResponder];
        });
    }
}

- (void)userPostsSelectedOriginalMorsel {
    [[MRSLEventManager sharedManager] track:@"Tapped Revert Morsel to Original Progression"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"post_id": NSNullIfNil(_morsel.post.postID)}];
    self.temporaryPostTitle = nil;
    self.post = self.morsel.post;
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.temporaryPostTitle = textField.text;
        self.userPostsViewController.temporaryPostTitle = _temporaryPostTitle;
        self.titleAlertView.hidden = YES;

        [textField setText:nil];
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

#pragma mark - UIDocumentInteractionControllerDelegate Methods

- (void)documentInteractionController:(UIDocumentInteractionController *)controller
        willBeginSendingToApplication:(NSString *)application {
    [[MRSLEventManager sharedManager] track:@"Tapped Send to Instagram"
                                 properties:@{@"view": @"CreateMorselViewController",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"morsel_social_message": _morsel.socialMessage}];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

@end