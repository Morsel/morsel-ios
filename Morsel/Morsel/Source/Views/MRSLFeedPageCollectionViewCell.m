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
@property (weak, nonatomic) IBOutlet UILabel *readMoreLabel;
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
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(toggleLike)];
    doubleTap.numberOfTapsRequired = 2;
    [self.itemImageView addGestureRecognizer:doubleTap];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (_item) [self populateContent];
        __weak __typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf) {
                [weakSelf.itemImageView removeBorder];
                [weakSelf.itemImageView addDefaultBorderForDirections:MRSLBorderSouth];
            }
        });
    });
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setItem:(MRSLItem *)item {
    _item = item;
    [self populateContent];
}

- (void)populateContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        _itemImageView.item = _item;

        [_itemDescriptionLabel setPreferredMaxLayoutWidth:[_itemDescriptionLabel getWidth]];
        _itemDescriptionLabel.text = _item.itemDescription;

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

        CGRect textRect = [_item.itemDescription boundingRectWithSize:CGSizeMake([_itemDescriptionLabel getWidth], CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName: _itemDescriptionLabel.font, NSParagraphStyleAttributeName: paragraphStyle}
                                                              context:nil];
        CGFloat floorHeight = floorf(textRect.size.height);
        CGFloat textHeight = self.itemDescriptionLabel.bounds.size.height;
        BOOL textTruncated = (floorHeight > textHeight);
        [_readMoreLabel setHidden:!textTruncated];
        [_viewMoreButton setHidden:!textTruncated];

        _profileImageView.user = _item.morsel.creator;
        _userNameLabel.text = [_item.morsel.creator fullName];
        _editButton.hidden = ![_item.morsel.creator isCurrentUser];
        _reportButton.hidden = !_editButton.hidden;

        [_likeCountButton setEnabled:(_item.like_countValue > 0)];
        [_likeCountButton setTitle:[NSString stringWithFormat:@"%@", (_item.like_countValue == 0) ? @"" : _item.like_count]
                          forState:UIControlStateNormal];
        [_commentCountButton setTitle:[NSString stringWithFormat:@"%@", (_item.comment_countValue == 0) ? @"" : _item.comment_count]
                             forState:UIControlStateNormal];

        UIImage *commentImage = [UIImage imageNamed:@"icon-comment-off"];
        [_commentButton setImage:commentImage
                        forState:UIControlStateNormal];

        [self setLikeButtonImageForMorsel:_item];

        if (![_item.morsel publishedDate]) {
            self.commentButton.enabled = NO;
            self.likeButton.enabled = NO;
            self.commentCountButton.enabled = NO;
            self.likeCountButton.enabled = NO;
            self.profileImageView.userInteractionEnabled = NO;
            self.editButton.hidden = YES;
        }
    });
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
