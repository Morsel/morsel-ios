//
//  MorselFeedCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLFeedCollectionViewCell.h"

#import "JSONResponseSerializerWithData.h"
#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedCollectionViewCell ()
<ProfileImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *plateButton;
@property (weak, nonatomic) IBOutlet UIButton *progressionButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLFeedCollectionViewCell

#pragma mark - Instance Methods

- (void)setItem:(MRSLItem *)item {
    if (_item != item) {
        [self reset];

        _item = item;

        _progressionButton.hidden = ([_item.morsel.items count] == 1);
        if (item.itemDescription) {
            CGSize descriptionHeight = [item.itemDescription sizeWithFont:_descriptionLabel.font
                                                        constrainedToSize:CGSizeMake(_descriptionLabel.frame.size.width, CGFLOAT_MAX)
                                                            lineBreakMode:NSLineBreakByWordWrapping];
            if (descriptionHeight.height > 16.f)
                [self.descriptionLabel setHeight:30.f];
            self.descriptionLabel.text = item.itemDescription;
        } else {
            [self.titleLabel setY:[self getHeight] - 80.f];
        }

        self.titleLabel.text = _item.morsel.title;
        [self.titleLabel sizeToFit];

        if ([self.titleLabel getWidth] > 240.f) [self.titleLabel setWidth:240.f];

        [self setLikeButtonImageForMorsel:_item];

        self.likeButton.hidden = [MRSLUser currentUserOwnsMorselWithCreatorID:_item.creator_idValue];
        self.editButton.hidden = !self.likeButton.hidden;
    }
    _itemImageView.item = _item;
    _profileImageView.user = _item.morsel.creator;
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
                                 properties:@{@"view": @"main_feed",
                                              @"item_id": NSNullIfNil(_item.itemID),
                                              @"morsel_id": NSNullIfNil(_item.morsel.morselID)}];

    if ([self.delegate respondsToSelector:@selector(itemMorselCollectionViewCellDidSelectEditMorsel:)]) {
        [self.delegate itemMorselCollectionViewCellDidSelectEditMorsel:self.item];
    }
}

- (IBAction)toggleLikeMorsel {
    _likeButton.enabled = NO;

    [[MRSLEventManager sharedManager] track:@"Tapped Like Icon"
                                 properties:@{@"view": @"main_feed",
                                              @"item_id": _item.itemID}];

    [_appDelegate.itemApiService likeItem:_item
                               shouldLike:!_item.likedValue
                                  didLike:^(BOOL doesLike) {
                                      [_item setLikedValue:doesLike];

                                      [self setLikeButtonImageForMorsel:_item];
                                  } failure: ^(NSError * error) {
                                      MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

                                      [UIAlertView showAlertViewForServiceError:serviceErrorInfo
                                                                       delegate:nil];

                                      _likeButton.enabled = YES;
                                  }];
}

- (void)setLikeButtonImageForMorsel:(MRSLItem *)item {
    UIImage *likeImage = [UIImage imageNamed:item.likedValue ? @"icon-like-active" : @"icon-like-inactive"];

    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];

    _likeButton.enabled = YES;
}

#pragma mark - ProfileImageViewDelegate

- (void)profileImageViewDidSelectUser:(MRSLUser *)user {
    [[MRSLEventManager sharedManager] track:@"Tapped Profile Picture"
                                 properties:@{@"view": @"main_feed",
                                              @"user_action_id": user.userID}];
    if ([self.delegate respondsToSelector:@selector(itemMorselCollectionViewCellDidSelectProfileForUser:)]) {
        [self.delegate itemMorselCollectionViewCellDidSelectProfileForUser:user];
    }
}

@end
