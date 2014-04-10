//
//  MRSLFeedShareCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedShareCollectionViewCell.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"
#import "MRSLSocialService.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedShareCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *shareCoverImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *previousMorselButton;

@end

@implementation MRSLFeedShareCollectionViewCell

#pragma mark - Instance Methods

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        [self populateContent];
    }
}

#pragma mark - Private Methods

- (void)populateContent {
    _shareCoverImageView.item = [_morsel coverItem];
    _profileImageView.user = _morsel.creator;
    _userNameLabel.text = _morsel.creator.fullName;
    _userTitleLabel.text = _morsel.creator.title;
    _userBioLabel.text = _morsel.creator.bio;
}

#pragma mark - Action Methods

- (IBAction)displayPreviousMorsel:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Prev Morsel"
                                 properties:@{@"view": @"main_feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectPreviousMorsel)]) {
        [self.delegate feedShareCollectionViewCellDidSelectPreviousMorsel];
    }
}

- (IBAction)displayNextMorsel:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Next Morsel"
                                 properties:@{@"view": @"main_feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectNextMorsel)]) {
        [self.delegate feedShareCollectionViewCellDidSelectNextMorsel];
    }
}

- (IBAction)shareToFacebook {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectShareFacebook)]) {
        [self.delegate feedShareCollectionViewCellDidSelectShareFacebook];
    }
}

- (IBAction)shareToTwitter {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectShareTwitter)]) {
        [self.delegate feedShareCollectionViewCellDidSelectShareTwitter];
    }
}

@end
