//
//  MRSLFeedCoverCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedCoverCollectionViewCell.h"

#import "MRSLMorselImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedCoverCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalMorselsLabel;

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *storyCoverImageView;

@property (strong, nonatomic) IBOutletCollection (MRSLMorselImageView) NSArray *storyMorselThumbnails;

@end

@implementation MRSLFeedCoverCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.storyMorselThumbnails = [_storyMorselThumbnails sortedArrayUsingComparator:^NSComparisonResult(MRSLMorselImageView *morselImageViewA, MRSLMorselImageView *morselImageViewB) {
        return [morselImageViewA getX] > [morselImageViewB getX];
    }];
}

- (void)setPost:(MRSLPost *)post {
    _post = post;

    _storyCoverImageView.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                            withValue:post.primary_morsel_id];
    if ([_post.morsels count] > 4) {
        self.additionalMorselsLabel.hidden = NO;
        self.additionalMorselsLabel.text = [NSString stringWithFormat:@"+%u", [_post.morsels count] - 4];
    } else {
        self.additionalMorselsLabel.hidden = YES;
    }
    _editButton.hidden = ![_post.creator isCurrentUser];
    _likeCountLabel.text = [NSString stringWithFormat:@"%i Like%@", _post.total_like_countValue, (_post.total_like_countValue == 1) ? @"" : @"s"];
    _commentCountLabel.text = [NSString stringWithFormat:@"%i Comment%@", _post.total_comment_countValue, (_post.total_comment_countValue == 1) ? @"" : @"s"];

    [_storyMorselThumbnails enumerateObjectsUsingBlock:^(MRSLMorselImageView *morselImageView, NSUInteger idx, BOOL *stop) {
        if (idx < [_post.morsels count]) {
            MRSLMorsel *morsel = [_post.morselsArray objectAtIndex:idx];
            morselImageView.morsel = morsel;
            morselImageView.hidden = NO;
        } else {
            morselImageView.morsel = nil;
            morselImageView.hidden = YES;
        }
    }];
}

@end
