//
//  MRSLFeedPageCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPageCollectionViewCell.h"

#import "MRSLAPIService+Like.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

static const CGFloat MRSLDescriptionHeightLimit = 60.f;

@interface MRSLFeedPageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeCountButton;
@property (weak, nonatomic) IBOutlet UIButton *commentCountButton;
@property (weak, nonatomic) IBOutlet UILabel *itemDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@property (weak, nonatomic) IBOutlet UIImageView *gradientView;

@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;

@end

@implementation MRSLFeedPageCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [_itemDescriptionLabel addStandardShadow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideContent)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
}

- (void)setItem:(MRSLItem *)item {
    _item = item;
    _itemImageView.item = _item;
    [self populateContent];
}

- (void)populateContent {
    _itemDescriptionLabel.text = _item.itemDescription;

    _gradientView.hidden = ([_item.itemDescription length] == 0);

    [_itemDescriptionLabel sizeToFit];
    [_itemDescriptionLabel setWidth:280.f];

    CGSize textSize = [_item.itemDescription sizeWithFont:_itemDescriptionLabel.font
                                        constrainedToSize:CGSizeMake([_itemDescriptionLabel getWidth], CGFLOAT_MAX)
                                            lineBreakMode:NSLineBreakByWordWrapping];

    if (textSize.height > MRSLDescriptionHeightLimit) {
        [_itemDescriptionLabel setHeight:MRSLDescriptionHeightLimit];
        [_viewMoreButton setHidden:NO];
    } else {
        [_itemDescriptionLabel setHeight:textSize.height];
        [_viewMoreButton setHidden:YES];
    }

    [_itemDescriptionLabel setY:[_itemImageView getY] + [_itemImageView getHeight] - ([_itemDescriptionLabel getHeight] + ((textSize.height > MRSLDescriptionHeightLimit) ? 30.f : 5.f))];

    _editButton.hidden = ![_item.morsel.creator isCurrentUser];

    [_likeCountButton setTitle:[NSString stringWithFormat:@"%i Like%@", _item.like_countValue, (_item.like_countValue != 1) ? @"s" : @""]
                      forState:UIControlStateNormal];
    [_commentCountButton setTitle:[NSString stringWithFormat:@"%i Comment%@", _item.comment_countValue, (_item.comment_countValue != 1) ? @"s" : @""]
                         forState:UIControlStateNormal];

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
                         [_commentButton setAlpha:shouldDisplay];
                         [_commentCountButton setAlpha:shouldDisplay];
                         [_likeButton setAlpha:shouldDisplay];
                         [_likeCountButton setAlpha:shouldDisplay];
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
    UIImage *likeImage = [UIImage imageNamed:item.likedValue ? @"icon-like-active" : @"icon-like-inactive"];

    [_likeButton setImage:likeImage
                 forState:UIControlStateNormal];

    _likeButton.enabled = YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
