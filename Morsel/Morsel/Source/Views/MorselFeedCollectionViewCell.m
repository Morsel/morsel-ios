//
//  MorselFeedCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselFeedCollectionViewCell.h"

#import "JSONResponseSerializerWithData.h"
#import "ModelController.h"
#import "MorselThumbnailViewController.h"
#import "ProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface MorselFeedCollectionViewCell ()
    <MorselThumbnailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *plateButton;
@property (weak, nonatomic) IBOutlet UIButton *progressionButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *morselImageView;

@property (nonatomic, weak) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) MorselThumbnailViewController *morselThumbnailVC;

@end

@implementation MorselFeedCollectionViewCell

#pragma mark - Instance Methods

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        [self reset];

        _morsel = morsel;

        if (_morsel) {
            _progressionButton.hidden = ([_morsel.post.morsels count] == 1);

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

            if ([self.titleLabel getWidth] > 240.f)
                [self.titleLabel setWidth:240.f];

            self.profileImageView.user = _morsel.post.author;

            [self.profileImageView addCornersWithRadius:20.f];
            self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            self.profileImageView.layer.borderWidth = 1.f;

            [self setLikeButtonImageForMorsel:_morsel];

            if (_morsel.morselPictureURL && !_morsel.isDraft) {
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

            if (_morsel.isDraft && _morsel.morselPictureCropped) {
                // This Morsel is a draft!

                _morselImageView.image = [UIImage imageWithData:_morsel.morselPictureCropped];
            }
        }

        if (_morsel.belongsToCurrentUser) {
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

    self.titleLabel.text = nil;
    self.descriptionLabel.text = nil;
    self.profileImageView.user = nil;
    self.morselImageView.image = nil;

    [self.titleLabel setY:148.f];
    [self.descriptionLabel setHeight:15.f];

    if (self.morselThumbnailVC) {
        [self.morselThumbnailVC.view removeFromSuperview];
        self.morselThumbnailVC = nil;

        _titleLabel.alpha = 1.f;
        _descriptionLabel.alpha = 1.f;
        _profileImageView.alpha = 1.f;
        _likeButton.alpha = 1.f;
    }
}

#pragma mark - Private Methods

- (IBAction)editMorsel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidSelectEditMorsel:)]) {
        [self.delegate morselPostCollectionViewCellDidSelectEditMorsel:self.morsel];
    }
}

- (IBAction)displayAssociatedMorsels:(id)sender {
    // Perform blur

    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidDisplayProgression:)]) {
        [self.delegate morselPostCollectionViewCellDidDisplayProgression:self];
    }

    self.morselThumbnailVC = [[UIStoryboard homeStoryboard] instantiateViewControllerWithIdentifier:@"MorselThumbnailViewController"];
    _morselThumbnailVC.delegate = self;
    _morselThumbnailVC.post = _morsel.post;
    [_morselThumbnailVC.view setX:self.frame.size.width];

    [self addSubview:_morselThumbnailVC.view];

    [UIView animateWithDuration:.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        _titleLabel.alpha = 0.f;
        _descriptionLabel.alpha = 0.f;
        _profileImageView.alpha = 0.f;
        _likeButton.alpha = 0.f;
        
        [_morselThumbnailVC.view setX:0.f];
                                }
                     completion:nil];
}

- (IBAction)displayUserProfile:(id)sender {
    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidSelectProfileForUser:)]) {
        [self.delegate morselPostCollectionViewCellDidSelectProfileForUser:_morsel.post.author];
    }
}

- (IBAction)toggleLikeMorsel {
    _likeButton.enabled = NO;

    [[ModelController sharedController].morselApiService likeMorsel:_morsel
                                                         shouldLike:!_morsel.likedValue
                                                            didLike:^(BOOL doesLike)
    {
        [_morsel setLikedValue:doesLike];

        [self setLikeButtonImageForMorsel:_morsel];
    } failure: ^(NSError * error) {
        NSDictionary *errorDictionary = error.userInfo[JSONResponseSerializerWithDataKey];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorDictionary ? [errorDictionary[@"errors"] objectAtIndex:0][@"msg"] : nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        _likeButton.enabled = YES;
    }];
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel {
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-active" : @"icon-like-inactive"];

    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];

    _likeButton.enabled = YES;
}

#pragma mark - MorselThumbnailViewControllerDelegate Methods

- (void)morselThumbnailDidSelectMorsel:(MRSLMorsel *)morsel {
    if ([self.delegate respondsToSelector:@selector(morselPostCollectionViewCellDidSelectMorsel:)]) {
        [self.delegate morselPostCollectionViewCellDidSelectMorsel:morsel];
    }
}

- (void)morselThumbnailDidSelectClose {
    if (self.morselThumbnailVC) {
        [UIView animateWithDuration:.3f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             _titleLabel.alpha = 1.f;
             _descriptionLabel.alpha = 1.f;
             _profileImageView.alpha = 1.f;
             _likeButton.alpha = 1.f;
             
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
