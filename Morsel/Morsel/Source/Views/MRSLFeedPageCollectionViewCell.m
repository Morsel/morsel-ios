//
//  MRSLFeedPageCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPageCollectionViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLAPIService+Like.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedPageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeCountButton;
@property (weak, nonatomic) IBOutlet UIButton *commentCountButton;
@property (weak, nonatomic) IBOutlet UILabel *itemDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@property (weak, nonatomic) IBOutlet UIView *descriptionPanelView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;

@end

@implementation MRSLFeedPageCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideContent)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    self.shareButton.hidden = (![[MRSLUser currentUser] isChef]);
}

- (void)setItem:(MRSLItem *)item {
    _item = item;
    _itemImageView.item = _item;
    [self populateContent];
}

- (void)populateContent {
    _itemDescriptionLabel.text = _item.itemDescription;

    CGSize textSize = [_item.itemDescription sizeWithFont:_itemDescriptionLabel.font
                                        constrainedToSize:CGSizeMake([_itemDescriptionLabel getWidth], CGFLOAT_MAX)
                                            lineBreakMode:NSLineBreakByWordWrapping];

    if (textSize.height < [_descriptionPanelView getHeight] - 34.f || [_item.itemDescription length] == 0) {
        [_itemDescriptionLabel setHeight:textSize.height];
        [_viewMoreButton setHidden:YES];
    } else {
        [_itemDescriptionLabel setHeight:[_descriptionPanelView getHeight] - 34.f];
        [_viewMoreButton setHidden:NO];
    }

    NSString *userNameString = [_item.morsel.creator fullName];
    CGSize nameSize = [userNameString sizeWithFont:self.userNameLabel.font
                                 constrainedToSize:CGSizeMake(self.userNameLabel.frame.size.width, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    if (nameSize.height > [self.userNameLabel getHeight]) {
        userNameString = [NSString stringWithFormat:@"%@ %@", _item.morsel.creator.first_name, ([_item.morsel.creator.last_name length] > 0) ? [NSString stringWithFormat:@"%@.", [_item.morsel.creator.last_name substringToIndex:1]] : @""];
    }

    _profileImageView.user = _item.morsel.creator;
    _userNameLabel.text = userNameString;
    _timeAgoLabel.text = [_item.morsel.creationDate timeAgo];
    _editButton.hidden = ![_item.morsel.creator isCurrentUser];

    [_likeCountButton setTitle:[NSString stringWithFormat:@"%i", _item.like_countValue]
                      forState:UIControlStateNormal];
    [_commentCountButton setTitle:[NSString stringWithFormat:@"%i", _item.comment_countValue]
                         forState:UIControlStateNormal];

    UIImage *commentImage = [UIImage imageNamed:(_item.comment_countValue > 0) ? @"icon-comment-on" : @"icon-comment-off"];
    [_commentButton setImage:commentImage
                    forState:UIControlStateNormal];

    if (![_viewMoreButton isHidden]) {
        [_viewMoreButton setHeight:[_itemDescriptionLabel getHeight] + 14.f];
    }

    [self setLikeButtonImageForMorsel:_item];
}

#pragma mark - Notification Methods

- (void)hideContent {
    [self toggleContent:NO];
}

- (void)showContent {
    [self toggleContent:YES];
}

- (void)updateContent:(NSNotification *)notification {
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];

    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if ([managedObject isKindOfClass:[MRSLItem class]]) {
            MRSLItem *item = (MRSLItem *)managedObject;
            if (item.itemIDValue == weakSelf.item.itemIDValue) {
                [weakSelf populateContent];
                *stop = YES;
            }
        }
    }];
}

#pragma mark - Private Methods

- (void)toggleContent:(BOOL)shouldDisplay {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_itemDescriptionLabel setAlpha:shouldDisplay];
                         [_viewMoreButton setAlpha:shouldDisplay];
                         [_shareButton setAlpha:shouldDisplay];
                         [_editButton setAlpha:shouldDisplay];
                     }];
}

#pragma mark - Action Methods

- (IBAction)toggleLike {
    _likeButton.enabled = NO;

    [[MRSLEventManager sharedManager] track:@"Tapped Like Icon"
                                 properties:@{@"view": @"main_feed",
                                              @"item_id": _item.itemID}];

    [_item setLikedValue:!_item.likedValue];
    [self setLikeButtonImageForMorsel:_item];

    [_appDelegate.apiService likeItem:_item
                           shouldLike:_item.likedValue
                              didLike:^(BOOL doesLike) {
                                  _likeButton.enabled = YES;
                              } failure: ^(NSError * error) {
                                  _likeButton.enabled = YES;
                                  [_item setLikedValue:!_item.likedValue];
                                  [_item setLike_countValue:_item.like_countValue - 1];
                                  [self setLikeButtonImageForMorsel:_item];
                              }];
}

- (void)setLikeButtonImageForMorsel:(MRSLItem *)item {
    UIImage *likeImage = [UIImage imageNamed:item.likedValue ? @"icon-like-on" : @"icon-like-off"];
    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];
    _likeButton.enabled = YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
