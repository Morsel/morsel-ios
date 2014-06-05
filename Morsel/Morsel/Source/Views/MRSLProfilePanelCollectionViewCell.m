//
//  MRSLProfilePanelReusableView.m
//  Morsel
//
//  Created by Javier Otero on 5/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfilePanelCollectionViewCell.h"

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLProfilePanelCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLProfilePanelCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    self.profileImageView.userInteractionEnabled = NO;
}

- (void)setUser:(MRSLUser *)user {
    _user = user;

    NSString *userNameString = [_user fullName];

    CGSize nameSize = [userNameString sizeWithFont:self.nameLabel.font
                                 constrainedToSize:CGSizeMake(self.nameLabel.frame.size.width, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    CGSize bioSize = [_user.bio sizeWithFont:self.bioLabel.font constrainedToSize:CGSizeMake(self.bioLabel.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];

    if (nameSize.height > [self.nameLabel getHeight]) {
        userNameString = [NSString stringWithFormat:@"%@ %@", _user.first_name, ([_user.last_name length] > 0) ? [NSString stringWithFormat:@"%@.", [_user.last_name substringToIndex:1]] : @""];
    }

    [self.bioLabel setHeight:bioSize.height];

    self.nameLabel.text = userNameString;
    self.bioLabel.text = _user.bio;
    self.profileImageView.user = nil;
    self.profileImageView.user = _user;
    [self.followersButton setTitle:[NSString stringWithFormat:@"%i Followers", _user.follower_countValue]
                          forState:UIControlStateNormal];
    [self.followingButton setTitle:[NSString stringWithFormat:@"%i Following", _user.followed_user_countValue]
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
