//
//  MRSLFeedShareCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedShareCollectionViewCell.h"

#import "MRSLMorselImageView.h"
#import "MRSLProfileImageView.h"
#import "MRSLSocialService.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedShareCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *shareCoverImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStoryButton;
@property (weak, nonatomic) IBOutlet UIButton *previousStoryButton;

@end

@implementation MRSLFeedShareCollectionViewCell

#pragma mark - Instance Methods

- (void)setPost:(MRSLPost *)post {
    if (_post != post) {
        _post = post;
        [self populateContent];
    }
}

#pragma mark - Private Methods

- (void)populateContent {
    _shareCoverImageView.morsel = [_post coverMorsel];
    _profileImageView.user = _post.creator;
    _userNameLabel.text = _post.creator.fullName;
    _userTitleLabel.text = _post.creator.title;
    _userBioLabel.text = _post.creator.bio;
}

#pragma mark - Action Methods

- (IBAction)displayPreviousStory:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Prev Post"
                                 properties:@{@"view": @"main_feed",
                                              @"post_id": NSNullIfNil(_post.postID)}];
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectPreviousStory)]) {
        [self.delegate feedShareCollectionViewCellDidSelectPreviousStory];
    }
}

- (IBAction)displayNextStory:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Next Post"
                                 properties:@{@"view": @"main_feed",
                                              @"post_id": NSNullIfNil(_post.postID)}];
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectNextStory)]) {
        [self.delegate feedShareCollectionViewCellDidSelectNextStory];
    }
}

- (IBAction)shareToFacebook {
    if ([[MRSLUser currentUser] facebook_uid]) {
        [self displayFacebookShare];
    } else {
        __weak __typeof(self) weakSelf = self;
        _facebookButton.enabled = NO;
        [[MRSLSocialService sharedService] activateFacebookInView:self
                                                         success:^(BOOL success) {
                                                             if (weakSelf) {
                                                                 weakSelf.facebookButton.enabled = YES;
                                                                 [weakSelf displayFacebookShare];
                                                             }
                                                         } failure:^(NSError *error) {
                                                             if (weakSelf) {
                                                                 weakSelf.facebookButton.enabled = YES;
                                                             }
                                                         }];
    }
}

- (IBAction)shareToTwitter {
    if ([[MRSLUser currentUser] twitter_username]) {
        [self displayTwitterShare];
    } else {
        __weak __typeof(self) weakSelf = self;
        _twitterButton.enabled = NO;
        [[MRSLSocialService sharedService] activateTwitterInView:self
                                                         success:^(BOOL success) {
                                                             if (weakSelf) {
                                                                 weakSelf.twitterButton.enabled = YES;
                                                                 [weakSelf displayTwitterShare];
                                                             }
                                                         } failure:^(NSError *error) {
                                                             if (weakSelf) {
                                                                 weakSelf.twitterButton.enabled = YES;
                                                             }
                                                         }];
    }
}

#pragma mark - Private Methods

- (void)displayFacebookShare {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectShareFacebook)]) {
        [self.delegate feedShareCollectionViewCellDidSelectShareFacebook];
    }
}

- (void)displayTwitterShare {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectShareTwitter)]) {
        [self.delegate feedShareCollectionViewCellDidSelectShareTwitter];
    }
}

@end
