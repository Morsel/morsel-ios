//
//  MorselFeedCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLFeedCollectionViewCell.h"

#import "JSONResponseSerializerWithData.h"
#import "MRSLThumbnailViewController.h"
#import "MRSLProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedCollectionViewCell ()
    <MorselThumbnailViewControllerDelegate,
     ProfileImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *plateButton;
@property (weak, nonatomic) IBOutlet UIButton *progressionButton;
@property (weak, nonatomic) IBOutlet UILabel *textOnlyLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *morselImageView;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) MRSLThumbnailViewController *morselThumbnailVC;

@end

@implementation MRSLFeedCollectionViewCell

#pragma mark - Instance Methods

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        [self reset];

        _morsel = morsel;

        if (_morsel) {
            _progressionButton.hidden = ([_morsel.post.morsels count] == 1);

            if (!_morsel.morselPhotoURL && _morsel.morselDescription) {
                self.titleLabel.hidden = YES;
                self.descriptionLabel.hidden = YES;
                
                self.textOnlyLabel.text = morsel.morselDescription;
                
            } else {
                self.textOnlyLabel.hidden = YES;
                
                if (morsel.morselDescription) {
                    CGSize descriptionHeight = [morsel.morselDescription sizeWithFont:_descriptionLabel.font
                                                                    constrainedToSize:CGSizeMake(_descriptionLabel.frame.size.width, CGFLOAT_MAX)
                                                                        lineBreakMode:NSLineBreakByWordWrapping];
                    if (descriptionHeight.height > 16.f)
                        [self.descriptionLabel setHeight:30.f];
                    self.descriptionLabel.text = morsel.morselDescription;
                } else {
                    [self.titleLabel setY:172.f];
                }
                
                self.titleLabel.text = _morsel.post.title;
                [self.titleLabel sizeToFit];
                
                if ([self.titleLabel getWidth] > 240.f) [self.titleLabel setWidth:240.f];
            }

            self.profileImageView.user = _morsel.post.creator;
            self.profileImageView.delegate = self;

            [self.profileImageView addCornersWithRadius:20.f];
            self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            self.profileImageView.layer.borderWidth = 1.f;

            [self setLikeButtonImageForMorsel:_morsel];

            if (_morsel.morselPhotoURL) {
                __weak __typeof(self) weakSelf = self;

                [_morselImageView setImageWithURLRequest:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeCropped]
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                {
                    if (image) {
                        weakSelf.morselImageView.image = image;
                    }
                }
            failure:
                ^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error)
                {
                    DDLogError(@"Unable to set Morsel Image: %@", error.userInfo);
                }];
            }
        }

        if ([MRSLUser currentUserOwnsMorselWithCreatorID:_morsel.creator_idValue]) {
            self.likeButton.hidden = YES;
            self.editButton.hidden = NO;
        } else {
            self.likeButton.hidden = NO;
            self.editButton.hidden = YES;
        }
    }
}

- (void)reset {
    [self.morselImageView cancelImageRequestOperation];

    self.titleLabel.hidden = NO;
    self.descriptionLabel.hidden = NO;
    self.textOnlyLabel.hidden = NO;

    self.titleLabel.text = nil;
    self.descriptionLabel.text = nil;
    self.profileImageView.user = nil;
    self.morselImageView.image = nil;

    [self.titleLabel setY:148.f];
    [self.descriptionLabel setHeight:15.f];

    if (self.morselThumbnailVC) {
        [self.morselThumbnailVC.view removeFromSuperview];
        self.morselThumbnailVC = nil;
        
        _progressionButton.enabled = YES;
        _likeButton.enabled = YES;
        _plateButton.enabled = YES;

        _titleLabel.alpha = 1.f;
        _descriptionLabel.alpha = 1.f;
        _profileImageView.alpha = 1.f;
        _likeButton.alpha = 1.f;
        _progressionButton.alpha = 1.f;
    }
}

#pragma mark - Private Methods

- (IBAction)editMorsel:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Edit Post"
                          properties:@{@"view": @"MRSLFeedCollectionViewCell",
                                       @"morsel_id": NSNullIfNil(_morsel.morselID),
                                       @"post_id": NSNullIfNil(_morsel.post.postID)}];

    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidSelectEditMorsel:)]) {
        [self.delegate morselPostCollectionViewCellDidSelectEditMorsel:self.morsel];
    }
}

- (IBAction)displayAssociatedMorsels:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Open Progression Thumbnail View"
                          properties:@{@"view": @"MRSLFeedCollectionViewCell",
                                       @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidDisplayProgression:)]) {
        [self.delegate morselPostCollectionViewCellDidDisplayProgression:self];
    }

    self.morselThumbnailVC = [[UIStoryboard homeStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselThumbnailViewController"];
    _morselThumbnailVC.delegate = self;
    _morselThumbnailVC.post = _morsel.post;
    [_morselThumbnailVC.view setX:self.frame.size.width];

    [self addSubview:_morselThumbnailVC.view];
    
    _progressionButton.enabled = NO;
    _likeButton.enabled = NO;
    _plateButton.enabled = NO;

    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _titleLabel.alpha = 0.f;
                         _descriptionLabel.alpha = 0.f;
                         _profileImageView.alpha = 0.f;
                         _likeButton.alpha = 0.f;
                         _progressionButton.alpha = 0.f;
        
        [_morselThumbnailVC.view setX:0.f];
                                }
                     completion:nil];
}

- (IBAction)toggleLikeMorsel {
    _likeButton.enabled = NO;

    [_appDelegate.morselApiService likeMorsel:_morsel
                                                         shouldLike:!_morsel.likedValue
                                                            didLike:^(BOOL doesLike)
    {
        [[MRSLEventManager sharedManager] track:(doesLike) ? @"Liked Morsel" : @"Unliked Morsel"
                              properties:@{@"view": @"MRSLFeedCollectionViewCell",
                                           @"morsel_id": _morsel.morselID}];
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

#pragma mark - MorselThumbnailViewControllerDelegate Methods

- (void)morselThumbnailDidSelectMorsel:(MRSLMorsel *)morsel {
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel Thumbnail"
                          properties:@{@"view": @"MRSLFeedCollectionViewCell",
                                       @"morsel_id": NSNullIfNil(morsel.morselID)}];
    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidSelectMorsel:)]) {
        [self.delegate morselPostCollectionViewCellDidSelectMorsel:morsel];
    }
}

- (void)morselThumbnailDidSelectClose {
    if (self.morselThumbnailVC) {
        [[MRSLEventManager sharedManager] track:@"Tapped Close Progression Thumbnail View"
                              properties:@{@"view": @"MRSLFeedCollectionViewCell",
                                           @"morsel_id": NSNullIfNil(_morsel.morselID)}];

        _progressionButton.enabled = YES;
        _likeButton.enabled = YES;
        _plateButton.enabled = YES;
        
        [UIView animateWithDuration:.3f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             _titleLabel.alpha = 1.f;
             _descriptionLabel.alpha = 1.f;
             _profileImageView.alpha = 1.f;
             _likeButton.alpha = 1.f;
             _progressionButton.alpha = 1.f;
             
             [_morselThumbnailVC.view setX:self.frame.size.width];
         }
                         completion:^(BOOL finished)
        {
            [self.morselThumbnailVC.view removeFromSuperview];
            self.morselThumbnailVC = nil;
        }];
    }
}

@end