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

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedShareCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *shareCoverImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
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
    _shareCoverImageView.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                            withValue:_post.primary_morsel_id] ?: [_post.morselsArray lastObject];
    _profileImageView.user = _post.creator;
    _userNameLabel.text = _post.creator.fullName;
    _userTitleLabel.text = _post.creator.title;
    _userBioLabel.text = _post.creator.bio;
}

#pragma mark - Action Methods

- (IBAction)displayPreviousStory:(id)sender {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectPreviousStory)]) {
        [self.delegate feedShareCollectionViewCellDidSelectPreviousStory];
    }
}

- (IBAction)displayNextStory:(id)sender {
    if ([self.delegate respondsToSelector:@selector(feedShareCollectionViewCellDidSelectNextStory)]) {
        [self.delegate feedShareCollectionViewCellDidSelectNextStory];
    }
}

@end
