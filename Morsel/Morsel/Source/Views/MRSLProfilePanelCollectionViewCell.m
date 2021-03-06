//
//  MRSLProfilePanelReusableView.m
//  Morsel
//
//  Created by Javier Otero on 5/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfilePanelCollectionViewCell.h"

#import "MRSLProfileImageView.h"
#import "MRSLPrimaryLabel.h"

#import "MRSLUser.h"

@interface MRSLProfilePanelCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLPrimaryLabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *blurProfileImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLProfilePanelCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    self.profileImageView.userInteractionEnabled = NO;
    self.blurProfileImageView.shouldBlur = YES;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setUser:(MRSLUser *)user {
    _user = user;

    self.nameLabel.text = [_user fullName];
    [_nameLabel setOblique:[_user hasEmptyName]];

    self.bioLabel.text = _user.bio;
    self.profileImageView.user = nil;
    self.profileImageView.user = _user;
    if (!self.blurProfileImageView.user) self.blurProfileImageView.user = _user;
    self.reportButton.hidden = [_user isCurrentUser];
    [self.followersButton setTitle:[NSString stringWithFormat:@"Followers: %i", _user.follower_countValue]
                          forState:UIControlStateNormal];
    [self.followingButton setTitle:[NSString stringWithFormat:@"Following: %i", _user.followed_user_countValue]
                          forState:UIControlStateNormal];
}

#pragma mark - Action Methods

- (IBAction)displayFollowers {
    if ([self.delegate respondsToSelector:@selector(profilePanelDidSelectFollowers)]) {
        [self.delegate profilePanelDidSelectFollowers];
    }
}

- (IBAction)displayFollowing {
    if ([self.delegate respondsToSelector:@selector(profilePanelDidSelectFollowing)]) {
        [self.delegate profilePanelDidSelectFollowing];
    }
}

@end
