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
    [_storyMorselThumbnails enumerateObjectsUsingBlock:^(MRSLMorselImageView *morselImageView, NSUInteger idx, BOOL *stop) {
        [morselImageView setBorderWithColor:[UIColor whiteColor]
                                    andWidth:2.f];
    }];
}

- (void)setPost:(MRSLPost *)post {
    if (_post != post) {
        _post = post;
        [self populateContent];
    }
}

- (void)populateContent {
    _storyCoverImageView.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                            withValue:_post.primary_morsel_id] ?: [_post.morselsArray lastObject];
    if ([_post.morsels count] > 4) {
        self.additionalMorselsLabel.hidden = NO;
        self.additionalMorselsLabel.text = [NSString stringWithFormat:@"+%lu", (unsigned long)[_post.morsels count] - 4];
    } else {
        self.additionalMorselsLabel.hidden = YES;
    }
    _editButton.hidden = ![_post.creator isCurrentUser];

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

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
