//
//  MRSLUserLikedMorselCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserLikedMorselCollectionViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLUserLikedMorselCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *creatorProfileImageView;

@property (weak, nonatomic) MRSLMorsel *morsel;
@property (weak, nonatomic) MRSLUser *user;

@end

@implementation MRSLUserLikedMorselCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor morselDefaultCellBackgroundColor]];
}

- (void)setMorsel:(MRSLMorsel *)morsel
          andUser:(MRSLUser *)user {
    if (_morsel != morsel) {
        _morsel = morsel;
        _user = user;
        
        self.descriptionLabel.text = [NSString stringWithFormat:@"%@ liked %@", [user username], [_morsel title]];
        [self.descriptionLabel sizeToFit];
        [self.descriptionLabel setWidth:160.f];
        self.timeAgoLabel.text = [morsel.likedDate timeAgo];
        self.itemImageView.item = morsel.coverItem;
        self.creatorProfileImageView.user = user;
    }
}

@end
