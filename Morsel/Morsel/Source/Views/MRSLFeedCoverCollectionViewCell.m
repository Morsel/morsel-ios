//
//  MRSLFeedCoverCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedCoverCollectionViewCell.h"

#import "NSDate+TimeAgoMinimized.h"

#import "MRSLItemImageView.h"
#import "MRSLPlaceViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLProfileViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLFeedCoverCollectionViewCell ()
<MRSLItemImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *placeButton;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCityStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *featuredImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clockImageView;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *morselCoverImageView;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *moreItemImageView;

@end

@implementation MRSLFeedCoverCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.placeNameLabel setPreferredMaxLayoutWidth:[self.placeNameLabel getWidth]];
    [self.userNameLabel setPreferredMaxLayoutWidth:[self.userNameLabel getWidth]];
    [self.morselTitleLabel removeStandardShadow];
    [self.morselTitleLabel addStandardShadow];
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf) {
            [weakSelf.morselCoverImageView removeBorder];
            [weakSelf.morselCoverImageView addDefaultBorderForDirections:MRSLBorderSouth];
        }
    });
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    _morsel = morsel;
    [self populateContent];
}

#pragma mark - Action Methods

- (IBAction)displayProfile {
    if (!_morsel.creator) return;
    UINavigationController *profileNC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileKey];
    MRSLProfileViewController *profileVC = [[profileNC viewControllers] firstObject];
    profileVC.user = _morsel.creator;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:profileNC];
}

- (IBAction)displayPlace {
    if (!_morsel.place) return;
    UINavigationController *placeNC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlaceKey];
    MRSLPlaceViewController *placeVC = [[placeNC viewControllers] firstObject];
    placeVC.place = _morsel.place;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:placeNC];
}

#pragma mark - Private Methods

- (void)populateContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.morselCoverImageView.item = [self.morsel coverItem];

        self.featuredImageView.hidden = !([self isHomeFeedItem] && _morsel.feedItemFeaturedValue);
        self.morselTitleLabel.text = _morsel.title;
        self.profileImageView.user = _morsel.creator;
        self.timeAgoLabel.text = [_morsel.publishedDate timeAgoMinimized];

        self.userNameLabel.text = [_morsel.creator fullName];

        _editButton.hidden = ![_morsel.creator isCurrentUser];
        _reportButton.hidden = !_editButton.hidden;

        MRSLItem *firstItem = [self.morsel.itemsArray firstObject];
        self.moreItemImageView.grayScale = YES;
        self.moreItemImageView.item = firstItem;
        self.moreItemImageView.delegate = self;

        _placeNameLabel.hidden = (!_morsel.place);
        _placeCityStateLabel.hidden = (!_morsel.place);
        _placeButton.enabled = (_morsel.place != nil);

        if (_morsel.place) {
            _placeNameLabel.text = _morsel.place.name;
            _placeCityStateLabel.text = [NSString stringWithFormat:@"%@, %@", _morsel.place.city, _morsel.place.state];
        }

        if (!_morsel.publishedDate) {
            self.timeAgoLabel.hidden = YES;
            self.clockImageView.hidden = YES;
            self.profileImageView.userInteractionEnabled = NO;
            self.editButton.hidden = YES;
            self.placeButton.enabled = NO;
        }
    });
}

#pragma mark - Notification Methods

- (void)updateContent:(NSNotification *)notification {
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];

    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if ([managedObject isKindOfClass:[MRSLMorsel class]]) {
            MRSLMorsel *morsel = (MRSLMorsel *)managedObject;
            if (morsel.morselIDValue == weakSelf.morsel.morselIDValue) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf populateContent];
                });
                *stop = YES;
            }
        }
    }];
}

#pragma mark - MRSLItemImageViewDelegate

- (void)itemImageViewDidSelectItem:(MRSLItem *)item {
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Morsel Thumbnail",
                                              @"_view": @"feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(item.itemID)}];
    if ([self.delegate respondsToSelector:@selector(feedCoverCollectionViewCellDidSelectMorsel:)]) {
        [self.delegate feedCoverCollectionViewCellDidSelectMorsel:item];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
