//
//  MorselFeedCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLFeedCollectionViewCell.h"

#import "JSONResponseSerializerWithData.h"
#import "MRSLMorselImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedCollectionViewCell ()
<ProfileImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *plateButton;
@property (weak, nonatomic) IBOutlet UIButton *progressionButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *morselImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLFeedCollectionViewCell

#pragma mark - Instance Methods

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        [self reset];

        _morsel = morsel;

        _progressionButton.hidden = ([_morsel.post.morsels count] == 1);
        if (morsel.morselDescription) {
            CGSize descriptionHeight = [morsel.morselDescription sizeWithFont:_descriptionLabel.font
                                                            constrainedToSize:CGSizeMake(_descriptionLabel.frame.size.width, CGFLOAT_MAX)
                                                                lineBreakMode:NSLineBreakByWordWrapping];
            if (descriptionHeight.height > 16.f)
                [self.descriptionLabel setHeight:30.f];
            self.descriptionLabel.text = morsel.morselDescription;
        } else {
            [self.titleLabel setY:[self getHeight] - 80.f];
        }

        self.titleLabel.text = _morsel.post.title;
        [self.titleLabel sizeToFit];

        if ([self.titleLabel getWidth] > 240.f) [self.titleLabel setWidth:240.f];

        [self setLikeButtonImageForMorsel:_morsel];

        self.likeButton.hidden = [MRSLUser currentUserOwnsMorselWithCreatorID:_morsel.creator_idValue];
        self.editButton.hidden = !self.likeButton.hidden;
    }
    _morselImageView.morsel = _morsel;
    _profileImageView.user = _morsel.post.creator;
    _profileImageView.delegate = self;
}

- (void)reset {
    self.titleLabel.hidden = NO;
    self.descriptionLabel.hidden = NO;

    self.titleLabel.text = nil;
    self.descriptionLabel.text = nil;

    [self.titleLabel setY:[self getHeight] - 56.f];
    [self.descriptionLabel setHeight:15.f];
}

#pragma mark - Private Methods

- (IBAction)editMorsel:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Edit Icon"
                                 properties:@{@"view": @"Feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"story_id": NSNullIfNil(_morsel.post.postID)}];

    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidSelectEditMorsel:)]) {
        [self.delegate morselPostCollectionViewCellDidSelectEditMorsel:self.morsel];
    }
}

- (IBAction)toggleLikeMorsel {
    _likeButton.enabled = NO;

    [[MRSLEventManager sharedManager] track:@"Tapped Like Icon"
                                 properties:@{@"view": @"Feed",
                                              @"morsel_id": _morsel.morselID}];

    [_appDelegate.morselApiService likeMorsel:_morsel
                                   shouldLike:!_morsel.likedValue
                                      didLike:^(BOOL doesLike) {
         [_morsel setLikedValue:doesLike];

         [self setLikeButtonImageForMorsel:_morsel];
     } failure: ^(NSError * error) {
         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

         [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                          delegate:nil];

         _likeButton.enabled = YES;
     }];
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel {
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-active" : @"icon-like-inactive"];

    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];

    _likeButton.enabled = YES;
}

#pragma mark - ProfileImageViewDelegate

- (void)profileImageViewDidSelectUser:(MRSLUser *)user {
    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidSelectProfileForUser:)]) {
        [self.delegate morselPostCollectionViewCellDidSelectProfileForUser:user];
    }
}

@end
