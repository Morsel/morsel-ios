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
#import "ModelController.h"
#import "UserPostsViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface CreateMorselViewController ()
    <AddTextViewControllerDelegate,
     CaptureMediaViewControllerDelegate,
     CreateMorselButtonPanelViewDelegate,
     UIActionSheetDelegate,
     UITextViewDelegate,
     UserPostsViewControllerDelegate>

@property (nonatomic) BOOL saveDraft;
@property (nonatomic) BOOL userIsEditing;
@property (nonatomic) BOOL imageUpdated;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *createTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *postMorselButton;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIView *titleAlertView;
@property (weak, nonatomic) IBOutlet UITextField *postTitleField;

@property (weak, nonatomic) IBOutlet CreateMorselButtonPanelView *createMorselButtonPanelView;

@property (nonatomic, strong) NSString *temporaryPostTitle;

@property (nonatomic, strong) AddTextViewController *addTextViewController;
@property (nonatomic, strong) UserPostsViewController *userPostsViewController;
@property (nonatomic, strong) MRSLPost *post;

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

    if (!_morsel.morselPictureURL && !_morsel.morselDescription) {
        // Entered through Morsel Creation

        self.createTitleLabel.text = @"Add Morsel";

        if (!_morsel) {
            MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:[ModelController sharedController].defaultContext];
            morsel.draft = @YES;

            self.morsel = morsel;
        }
    } else {
        // Entered through Edit Morsel. Setting states.

        self.createTitleLabel.text = @"Edit Morsel";

        self.userIsEditing = YES;

        if (!_post) {
            self.post = _morsel.post;

            if (_morsel.morselPictureURL && !_morsel.isDraft) {
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

            if (!_morsel.isDraft && _morsel.morselThumb) {
                self.thumbnailImageView.image = [UIImage imageWithData:_morsel.morselThumb];
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
        [[ModelController sharedController].defaultContext deleteObject:_morsel];

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

- (IBAction)postMorsel {
    if (!self.addTextViewController.textView.text && !_capturedImage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Error."
                                                        message:@"Please add content to the Morsel."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];

        [alert show];
        return;
    }

    if (_userIsEditing) {
        [self updateMorsel];
        return;
    }

    [self.view bringSubviewToFront:_activityView];
    self.activityView.hidden = NO;

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

        [_morsel.post removeMorsel:_morsel];
        [_post addMorsel:_morsel];

        _morsel.post = _post;
    }

    if (self.addTextViewController.textView.text)
        _morsel.morselDescription = self.addTextViewController.textView.text;

    if (_imageUpdated)
        [self addMediaDataToCurrentMorsel];

    __weak __typeof(self) weakSelf = self;

    [[ModelController sharedController].morselApiService updateMorsel:_morsel
                                                              success:^(id responseObject)
    {
        [[ModelController sharedController] saveDataToStoreWithSuccess:^(BOOL success)
        {
            if (weakSelf) {
                [weakSelf goBack];
            }
        }
    failure:nil];
    } failure: ^(NSError * error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong."
                                                            message:@"Unable to update Morsel!"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }];
}

- (void)saveAsDraft {
    if (_morsel) {
        if (!self.post) {
            // Creating a temporary draft post

            MRSLPost *post = [MRSLPost MR_createInContext:[ModelController sharedController].defaultContext];
            post.draft = @YES;
            post.author = [ModelController sharedController].currentUser;

            if (self.temporaryPostTitle) {
                post.title = _temporaryPostTitle;
            }

            _morsel.post = post;
            [post addMorsel:_morsel];
        } else {
            // Adding Draft Morsel to existing Post!

            if (self.temporaryPostTitle) {
                _post.title = _temporaryPostTitle;
            }

            _morsel.post = _post;
            [_post addMorsel:_morsel];
        }

        if (self.addTextViewController.textView.text)
            _morsel.morselDescription = self.addTextViewController.textView.text;

        _morsel.creationDate = [NSDate date];
    }

    if (_capturedImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self addMediaDataToCurrentMorsel];
            
            UIImage *thumbImage = [_capturedImage thumbnailImage:104.f
                                            interpolationQuality:kCGInterpolationHigh];
            
            _morsel.morselThumb = UIImageJPEGRepresentation(thumbImage, 1.f);
            
            BOOL imageIsLandscape = [Util imageIsLandscape:_capturedImage];
            CGFloat cameraDimensionScale = [Util cameraDimensionScaleFromImage:_capturedImage];
            CGFloat cropStartingY = yCameraImagePreviewOffset * cameraDimensionScale;
            CGFloat minimumImageDimension = (imageIsLandscape) ? _capturedImage.size.height : _capturedImage.size.width;
            CGFloat maximumImageDimension = (imageIsLandscape) ? _capturedImage.size.width : _capturedImage.size.height;
            CGFloat xCenterAdjustment = (maximumImageDimension - minimumImageDimension) / 2.f;
            CGFloat cropHeightAmount = croppedImageHeightOffset * (imageIsLandscape ? cameraDimensionScale + 2.f : cameraDimensionScale);
            
            UIImage *croppedImage = [_capturedImage croppedImage:CGRectMake((imageIsLandscape) ? xCenterAdjustment : 0.f, (imageIsLandscape) ? 0.f : cropStartingY, minimumImageDimension, minimumImageDimension - cropHeightAmount)
                                                          scaled:CGSizeMake(320.f, 214.f)];
            
            _morsel.morselPictureCropped = UIImageJPEGRepresentation(croppedImage, 1.f);
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [[ModelController sharedController] saveDataToStoreWithSuccess:nil
                                                                       failure:nil];
            });
        });
    }

    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)publishMorsel {
    if (self.post) {
        if (self.temporaryPostTitle) {
            _post.title = _temporaryPostTitle;
        }

        _post.author = [ModelController sharedController].currentUser;

        _morsel.post = _post;
        [_post addMorsel:_morsel];
    }

    if (self.addTextViewController.textView.text)
        _morsel.morselDescription = self.addTextViewController.textView.text;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addMediaDataToCurrentMorsel];
        
        [[ModelController sharedController].morselApiService createMorsel:_morsel
                                                                  success:^(id responseObject)
         {
             [[ModelController sharedController] saveDataToStoreWithSuccess:nil
                                                                    failure:nil];
         }
                                                                  failure:^(NSError *error)
         {
             /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, error publishing Morsel."
                                                             message:[NSString stringWithFormat:@"Error: %@", error.userInfo[JSONResponseSerializerWithDataKey]]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             
             [alert show];
             
             DDLogError(@"Error! Unable to create Morsel: %@", error.userInfo[JSONResponseSerializerWithDataKey]);
             
             self.activityView.hidden = YES;
              */
         }];
    });

    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)displaySettings {
    NSArray *buttonTitles = nil;

    if (!_userIsEditing) {
        buttonTitles = [NSArray arrayWithObjects:@"Publish Now", @"Save Draft", nil];
    }

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Settings"
                                                             delegate:self
                                                    cancelButtonTitle:_userIsEditing ? @"Cancel" : nil
                                               destructiveButtonTitle:_userIsEditing ? @"Delete Morsel" : nil
                                                    otherButtonTitles:nil];

    if (!_userIsEditing) {
        for (NSString *buttonTitle in buttonTitles) {
            [actionSheet addButtonWithTitle:buttonTitle];
        }
    }

    [actionSheet showInView:self.view];
}

#pragma mark - Image Processing Methods

- (void)addMediaDataToCurrentMorsel {
    BOOL imageIsLandscape = [Util imageIsLandscape:_capturedImage];
    CGFloat cameraDimensionScale = [Util cameraDimensionScaleFromImage:_capturedImage];
    CGFloat cropStartingY = yCameraImagePreviewOffset * cameraDimensionScale;
    CGFloat minimumImageDimension = (imageIsLandscape) ? _capturedImage.size.height : _capturedImage.size.width;
    CGFloat maximumImageDimension = (imageIsLandscape) ? _capturedImage.size.width : _capturedImage.size.height;
    CGFloat xCenterAdjustment = (maximumImageDimension - minimumImageDimension) / 2.f;

    UIImage *processedImage = [_capturedImage croppedImage:CGRectMake((imageIsLandscape) ? xCenterAdjustment : 0.f, (imageIsLandscape) ? 0.f : cropStartingY, minimumImageDimension, minimumImageDimension)
                                                    scaled:CGSizeZero];

    _morsel.morselPicture = UIImageJPEGRepresentation(processedImage, 1.f);
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_userIsEditing) {
        if (buttonIndex == 0) {
            [[ModelController sharedController].morselApiService deleteMorsel:_morsel
                                                                      success:^(BOOL success)
            {

                [self goBack];
            } failure: ^(NSError * error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong."
                                                                    message:@"Unable to delete Morsel!"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                [alertView show];
            }];
        }
    } else {
        self.saveDraft = (buttonIndex == 1);

        [self.postMorselButton setTitle:_saveDraft ? @"Save Morsel" : @"Publish Morsel"
                               forState:UIControlStateNormal];
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
