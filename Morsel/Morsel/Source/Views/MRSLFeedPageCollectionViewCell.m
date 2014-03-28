//
//  MRSLFeedPageCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPageCollectionViewCell.h"

#import "MRSLMorselImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedPageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselDescriptionLabel;

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *morselImageView;

@end

@implementation MRSLFeedPageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [_morselDescriptionLabel addStandardShadow];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    _morsel = morsel;

    _morselImageView.morsel = _morsel;
    _morselDescriptionLabel.text = _morsel.morselDescription;

    [_morselDescriptionLabel sizeToFit];
    [_morselDescriptionLabel setWidth:280.f];

    CGSize textSize = [_morsel.morselDescription sizeWithFont:_morselDescriptionLabel.font constrainedToSize:CGSizeMake([_morselDescriptionLabel getWidth], CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat threeLineHeight = [_morselDescriptionLabel getHeight] * 3;
    if (textSize.height > threeLineHeight) {
        [_morselDescriptionLabel setHeight:threeLineHeight];
        // Display View More
    } else {
        [_morselDescriptionLabel setHeight:textSize.height];
    }

    [_morselDescriptionLabel setY:[_morselImageView getY] + [_morselImageView getHeight] - ([_morselDescriptionLabel getHeight] + 5.f)];

    _editButton.hidden = ![_morsel.post.creator isCurrentUser];
    _likeCountLabel.text = [NSString stringWithFormat:@"%i", _morsel.like_countValue];
    _commentCountLabel.text = [NSString stringWithFormat:@"%i", _morsel.comment_countValue];

    [_likeCountLabel sizeToFit];
    [_commentCountLabel sizeToFit];
}

@end
