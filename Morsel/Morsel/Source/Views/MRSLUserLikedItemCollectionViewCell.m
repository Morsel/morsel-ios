//
//  MRSLUserLikedItemCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserLikedItemCollectionViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLUserLikedItemCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *creatorProfileImageView;

@property (weak, nonatomic) MRSLItem *item;
@property (weak, nonatomic) MRSLUser *user;

@end

@implementation MRSLUserLikedItemCollectionViewCell

- (void)setItem:(MRSLItem *)item
        andUser:(MRSLUser *)user {
    if (_item != item) {
        _item = item;
        _user = user;

        self.descriptionLabel.text = [NSString stringWithFormat:@"%@ liked %@", [user username], [_item displayName]];
        [self.descriptionLabel sizeToFit];
        [self.descriptionLabel setWidth:160.f];
        self.timeAgoLabel.text = [item.likedDate timeAgo];
        self.itemImageView.item = item;
        self.creatorProfileImageView.user = user;
    }
}


@end
