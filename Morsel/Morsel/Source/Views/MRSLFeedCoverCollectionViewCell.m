//
//  MRSLFeedCoverCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedCoverCollectionViewCell.h"

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedCoverCollectionViewCell ()
<MRSLItemImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *additionalMorselsLabel;

@property (weak, nonatomic) IBOutlet MRSLItemImageView *morselCoverImageView;

@property (strong, nonatomic) IBOutletCollection (MRSLItemImageView) NSArray *morselItemThumbnails;

@end

@implementation MRSLFeedCoverCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];

    self.morselItemThumbnails = [_morselItemThumbnails sortedArrayUsingComparator:^NSComparisonResult(MRSLItemImageView *itemImageViewA, MRSLItemImageView *itemImageViewB) {
        return [itemImageViewA getX] > [itemImageViewB getX];
    }];
    [_morselItemThumbnails enumerateObjectsUsingBlock:^(MRSLItemImageView *itemImageView, NSUInteger idx, BOOL *stop) {
        [itemImageView setBorderWithColor:[UIColor whiteColor]
                                 andWidth:2.f];
        itemImageView.delegate = self;
    }];
    [_additionalMorselsLabel addStandardShadow];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        [self populateContent];
    }
}

#pragma mark - Private Methods

- (void)populateContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        _morselCoverImageView.item = [_morsel coverItem];
        if ([_morsel.items count] > 4) {
            self.additionalMorselsLabel.hidden = NO;
            self.additionalMorselsLabel.text = [NSString stringWithFormat:@"+%lu", (unsigned long)[_morsel.items count] - 4];
        } else {
            self.additionalMorselsLabel.hidden = YES;
        }
        _editButton.hidden = ![_morsel.creator isCurrentUser];

        [_morselItemThumbnails enumerateObjectsUsingBlock:^(MRSLItemImageView *itemImageView, NSUInteger idx, BOOL *stop) {
            if (idx < [_morsel.items count] && [_morsel.items count] != 1) {
                MRSLItem *item = [_morsel.itemsArray objectAtIndex:idx];
                itemImageView.item = item;
                itemImageView.hidden = NO;
            } else {
                itemImageView.item = nil;
                itemImageView.hidden = YES;
            }
        }];
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

- (void)itemImageViewDidSelectMorsel:(MRSLItem *)item {
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel Thumbnail"
                                 properties:@{@"view": @"main_feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(item.itemID)}];
    if ([self.delegate respondsToSelector:@selector(feedCoverCollectionViewCellDidSelectMorsel:)]) {
        [self.delegate feedCoverCollectionViewCellDidSelectMorsel:item];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
