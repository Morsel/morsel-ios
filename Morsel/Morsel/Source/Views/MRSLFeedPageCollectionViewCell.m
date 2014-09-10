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

#import "MRSLProfileViewController.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedPageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *likeCountButton;
@property (weak, nonatomic) IBOutlet UIButton *commentCountButton;
@property (weak, nonatomic) IBOutlet UILabel *itemDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@property (weak, nonatomic) IBOutlet UIView *descriptionPanelView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

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

    [self.itemImageView addDefaultBorderForDirections:MRSLBorderSouth];
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

    CGFloat maxDescriptionHeight = [_descriptionPanelView getHeight] - ([UIDevice has35InchScreen] ? 15.0f : 20.f);
    [_itemDescriptionLabel setY:0.f];
    if (textSize.height < maxDescriptionHeight || [_item.itemDescription length] == 0) {
        [_itemDescriptionLabel setHeight:textSize.height];
        [_viewMoreButton setHidden:YES];
        if (![UIDevice has35InchScreen]) {
            [_itemDescriptionLabel setY:6.f];
        }
    } else {
        [_itemDescriptionLabel setHeight:MAX(maxDescriptionHeight, 0)];
        [_viewMoreButton setHidden:NO];
    }

    _profileImageView.user = _item.morsel.creator;
    _userNameLabel.text = [_item.morsel.creator fullName];
    _editButton.hidden = ![_item.morsel.creator isCurrentUser];
    _reportButton.hidden = !_editButton.hidden;

    [_likeCountButton setTitle:[NSString stringWithFormat:@"%i", _item.like_countValue]
                      forState:UIControlStateNormal];
    [_commentCountButton setTitle:[NSString stringWithFormat:@"%i", _item.comment_countValue]
                         forState:UIControlStateNormal];

    UIImage *commentImage = [UIImage imageNamed:(_item.comment_countValue > 0) ? @"icon-comment-on" : @"icon-comment-off"];
    [_commentButton setImage:commentImage
                    forState:UIControlStateNormal];

    if (![_viewMoreButton isHidden]) {
        [_viewMoreButton setHeight:[_itemDescriptionLabel getY] + [_itemDescriptionLabel getHeight] + 14.f];
    }

    [self setLikeButtonImageForMorsel:_item];

    if (![_item.morsel publishedDate]) {
        self.commentButton.enabled = NO;
        self.likeButton.enabled = NO;
        self.commentCountButton.enabled = NO;
        self.likeCountButton.enabled = NO;
        self.profileImageView.userInteractionEnabled = NO;
        self.editButton.hidden = YES;
    }
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
                         [_editButton setAlpha:shouldDisplay];
                     }];
}

#pragma mark - Action Methods

- (IBAction)displayProfile {
    UINavigationController *profileNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileKey];
    MRSLProfileViewController *profileVC = [[profileNC viewControllers] firstObject];
    profileVC.user = _item.morsel.creator;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:profileNC];
}

- (IBAction)toggleLike {
    if ([MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    _likeButton.enabled = NO;
    if (!_item.managedObjectContext) return;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Like Icon",
                                              @"_view": @"feed",
                                              @"item_id": _item.itemID}];

    [_item setLikedValue:!_item.likedValue];
    [self setLikeButtonImageForMorsel:_item];

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService likeItem:_item
                           shouldLike:_item.likedValue
                              didLike:^(BOOL doesLike) {
                                  if (weakSelf.item.likedValue) [MRSLEventManager sharedManager].likes_given++;
                                  weakSelf.likeButton.enabled = YES;
                              } failure: ^(NSError * error) {
                                  weakSelf.likeButton.enabled = YES;
                                  [weakSelf.item setLikedValue:!weakSelf.item.likedValue];
                                  [weakSelf.item setLike_countValue:weakSelf.item.like_countValue - 1];
                                  [weakSelf setLikeButtonImageForMorsel:weakSelf.item];
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
