//
//  CreateMorselViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "CreateMorselViewController.h"

#import "GCPlaceholderTextView.h"
#import "JSONResponseSerializerWithData.h"
#import "ModelController.h"
#import "UserPostsViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface CreateMorselViewController ()

<
UIActionSheetDelegate,
UITextViewDelegate
>

@property (nonatomic) BOOL saveDraft;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *topRightButton;
@property (weak, nonatomic) IBOutlet UIButton *addToProgressionButton;
@property (weak, nonatomic) IBOutlet UIButton *postMorselButton;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *descriptionTextView;

@property (nonatomic, strong) NSString *postTitle;

@property (nonatomic, strong) MRSLMorsel *morsel;
@property (nonatomic, strong) MRSLPost *post;

@end

@implementation CreateMorselViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.addToProgressionButton.enabled = !([[ModelController sharedController].currentUser.posts count] == 0);
    
    _descriptionTextView.placeholder = @"Tell us more about this";
    _descriptionTextView.placeholderColor = [UIColor morselLightContent];
    
    _descriptionTextView.layer.borderColor = [UIColor morselRed].CGColor;
    _descriptionTextView.layer.borderWidth = 1.f;
    
    _thumbnailImageView.layer.borderColor = [UIColor morselRed].CGColor;
    _thumbnailImageView.layer.borderWidth = 1.f;
    
    MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:[ModelController sharedController].defaultContext];
    morsel.draft = [NSNumber numberWithBool:YES];

    self.morsel = morsel;
    
    if (!_thumbnailImageView.image)
    {
        [self renderThumbnail];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)setCapturedImage:(UIImage *)capturedImage
{
    if (_capturedImage != capturedImage)
    {
        _capturedImage = capturedImage;
        
        [self renderThumbnail];
    }
}

- (void)renderThumbnail
{
    if (_capturedImage)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
        {
            UIImage *thumbnailImage = [_capturedImage thumbnailImage:50.f
                                                interpolationQuality:kCGInterpolationHigh];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _thumbnailImageView.image = thumbnailImage;
            });
        });
    }
}

#pragma mark - Private Methods

- (IBAction)goBackToCaptureMedia:(id)sender
{
    [[ModelController sharedController].defaultContext deleteObject:_morsel];
    
    if (_capturedImage)
    {
        self.thumbnailImageView.image = nil;
        self.capturedImage = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)associateMorselToPost
{
    [self performSegueWithIdentifier:@"AddMorselToPost"
                              sender:nil];
}

- (IBAction)postMorsel
{
#warning If appended to progression, make sure sort_order is set?
    
    if (!_descriptionTextView.text &&
        !_capturedImage)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Error."
                                                        message:@"Please add content to the Morsel."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    self.activityView.hidden = NO;
    
    if (_saveDraft)
    {
        [self saveAsDraft];
    }
    else
    {
        [self publishMorsel];
    }
}

- (void)saveAsDraft
{
    if (_morsel)
    {
        if (!self.post)
        {
            // Creating a temporary draft post
            
            MRSLPost *post = [MRSLPost MR_createInContext:[ModelController sharedController].defaultContext];
            post.draft = [NSNumber numberWithBool:YES];
            post.author = [ModelController sharedController].currentUser;
            
            if (self.postTitle)
            {
                post.title = _postTitle;
            }
            
            _morsel.post = post;
            [post addMorsel:_morsel];
        }
        else
        {
            // Adding Draft Morsel to existing Post!
            
            if (self.postTitle)
            {
                _post.title = _postTitle;
            }
            
            _morsel.post = _post;
            [_post addMorsel:_morsel];
        }
        
        if (_descriptionTextView.text) _morsel.morselDescription = _descriptionTextView.text;
        
        _morsel.creationDate = [NSDate date];
    }
    
    if (_capturedImage)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            _morsel.morselPicture = UIImageJPEGRepresentation(_capturedImage, 1.f);
            
            UIImage *thumbImage = [_capturedImage thumbnailImage:104.f
                                            interpolationQuality:kCGInterpolationHigh];
            
            _morsel.morselThumb = UIImageJPEGRepresentation(thumbImage, 1.f);;
            
            CGFloat cameraDimensionScale = minimumCameraMaxDimension / self.view.frame.size.height;
            CGFloat yScale = (minimumCameraMaxDimension * cameraDimensionScale) / _capturedImage.size.height;
            CGFloat cropStartingY = yPreviewOffset * yScale;
            CGFloat cropHeightAmount = croppedHeightOffset * yScale;
            
            UIImage *croppedImage = [_capturedImage croppedImage:CGRectMake(0.f, cropStartingY, _capturedImage.size.width, _capturedImage.size.width - cropHeightAmount)
                                                          scaled:CGSizeMake(320.f, 214.f)];
            
            _morsel.morselPictureCropped = UIImageJPEGRepresentation(croppedImage, 1.f);
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [[ModelController sharedController] saveDataToStore];
            });
        });
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)publishMorsel
{
    if (self.post)
    {
        if (self.postTitle)
        {
            _post.title = _postTitle;
        }
        
        _post.author = [ModelController sharedController].currentUser;
        
        _morsel.post = _post;
        [_post addMorsel:_morsel];
    }
    
    if (_descriptionTextView.text) _morsel.morselDescription = _descriptionTextView.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        _morsel.morselPicture = UIImageJPEGRepresentation(_capturedImage, 1.f);
        
        [[ModelController sharedController].morselApiService createMorsel:_morsel
                                                                  success:^(id responseObject)
         {
             [[ModelController sharedController] saveDataToStore];
             
             [self.presentingViewController dismissViewControllerAnimated:YES
                                                               completion:nil];
         }
                                                                  failure:^(NSError *error)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, error publishing Morsel."
                                                             message:[NSString stringWithFormat:@"Error: %@", error.userInfo[JSONResponseSerializerWithDataKey]]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             
             [alert show];
             
             DDLogError(@"Error! Unable to create Morsel: %@", error.userInfo[JSONResponseSerializerWithDataKey]);
             
             self.activityView.hidden = YES;
         }];
    });
}

- (IBAction)displaySettingsOrDismissResponder:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"Done"])
    {
        [self.view endEditing:YES];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Settings"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Publish Now", @"Save Draft", nil];
        
        [actionSheet showInView:self.view];
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AddMorselToPost"])
    {
        if (_post)
        {
            // Post existed. Be sure to highlight it in the user posts collection view
            UserPostsViewController *userPostsVC = [segue destinationViewController];
            userPostsVC.post = _post;
            userPostsVC.postTitle = _postTitle;
        }
    }
}

- (IBAction)didSelectPostForProgressionAssociation:(UIStoryboardSegue *)segue
{
    UserPostsViewController *userPostsVC = [segue sourceViewController];
    
    self.post = userPostsVC.post;
    self.postTitle = userPostsVC.postTitle;
    
    [self.addToProgressionButton setTitle:(_post) ? @"Change Associated Progression" : @"Add Morsel to Progression"
                                 forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.topRightButton setTitle:@"Done"
                         forState:UIControlStateNormal];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.topRightButton setTitle:@"Settings"
                         forState:UIControlStateNormal];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.saveDraft = (buttonIndex == 1);
    
    [self.postMorselButton setTitle:_saveDraft ? @"Save Morsel" : @"Publish Morsel"
                           forState:UIControlStateNormal];
}

@end
