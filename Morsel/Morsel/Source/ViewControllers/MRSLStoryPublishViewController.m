//
//  MRSLStorySettingsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryPublishViewController.h"

#import "MRSLSocialService.h"
#import "MRSLMorselImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLStoryPublishViewController ()
<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet MRSLMorselImageView *coverMorselImageView;

@property (strong, nonatomic) UIBarButtonItem *publishButton;

@end

@implementation MRSLStoryPublishViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _coverMorselImageView.morsel = [_post coverMorsel];
    _storyTitleLabel.text = _post.title;
    [_storyTitleLabel addStandardShadow];
}

#pragma mark - Private Methods

- (IBAction)publishStory:(id)sender {
    _publishButton.enabled = NO;
    _post.draft = @NO;
    [_appDelegate.morselApiService updatePost:_post
                                      success:^(id responseObject) {
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidPublishPostNotification
                                                                                              object:_post];
                                      } failure:^(NSError *error) {
                                          _publishButton.enabled = YES;
                                          [UIAlertView showAlertViewForErrorString:@"Unable to publish Story, please try again!"
                                                                          delegate:nil];
                                      }
                               postToFacebook:_facebookButton.selected
                                postToTwitter:_twitterButton.selected];
}

- (IBAction)toggleFacebook:(UIButton *)button {
    MRSLUser *currentUser = [MRSLUser currentUser];
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Facebook"
                                 properties:@{@"view": @"Publish",
                                              @"post_id": NSNullIfNil(_post.postID)}];

    if ([currentUser facebook_uid]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Facebook"
                                     properties:@{@"view": @"Publish",
                                                  @"post_id": NSNullIfNil(_post.postID)}];
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        _facebookButton.enabled = NO;

        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialService sharedService] activateFacebookInView:self.view
                                                          success:^(BOOL success) {
                                                              if (weakSelf) {
                                                                  [[MRSLEventManager sharedManager] track:@"Tapped Share Own Post"
                                                                                               properties:@{@"view": @"Publish",
                                                                                                            @"post_id": NSNullIfNil(weakSelf.post.postID),
                                                                                                            @"creator_id": NSNullIfNil(weakSelf.post.creator.userID),
                                                                                                            @"social_type": @"facebook"}];
                                                                  [weakSelf.facebookButton setEnabled:YES];
                                                                  [weakSelf.facebookButton setSelected:!weakSelf.facebookButton.selected];
                                                              }
        } failure:^(NSError *error) {
            if (weakSelf) {
            [weakSelf.facebookButton setEnabled:YES];
            [UIAlertView showAlertViewForError:error
                                      delegate:nil];
            }
        }];
    }
}

- (IBAction)toggleTwitter:(UIButton *)button {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Twitter"
                                 properties:@{@"view": @"Publish",
                                              @"post_id": NSNullIfNil(_post.postID)}];
    MRSLUser *currentUser = [MRSLUser currentUser];

    if ([currentUser twitter_username]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Twitter"
                                     properties:@{@"view": @"Publish",
                                                  @"post_id": NSNullIfNil(_post.postID)}];
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        _twitterButton.enabled = NO;

        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialService sharedService] activateTwitterInView:self.view
                                                         success:^(BOOL success) {
                                                             if (weakSelf) {
                                                                 [[MRSLEventManager sharedManager] track:@"Tapped Share Own Post"
                                                                                              properties:@{@"view": @"Publish",
                                                                                                           @"post_id": NSNullIfNil(weakSelf.post.postID),
                                                                                                           @"creator_id": NSNullIfNil(weakSelf.post.creator.userID),
                                                                                                           @"social_type": @"twitter"}];
                                                                 [weakSelf.twitterButton setEnabled:YES];
                                                                 [weakSelf.twitterButton setSelected:!weakSelf.twitterButton.selected];
                                                             }
        } failure:^(NSError *error) {
            if (weakSelf) {
                [weakSelf.twitterButton setEnabled:YES];
                [UIAlertView showAlertViewForError:error
                                          delegate:nil];
            }
        }];
    }
}

@end
