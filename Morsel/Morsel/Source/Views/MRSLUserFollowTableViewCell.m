//
//  MRSLUserFollowTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserFollowTableViewCell.h"

#import "MRSLFollowButton.h"
#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLUserFollowTableViewCell ()

@property (weak, nonatomic) IBOutlet MRSLFollowButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userFullNameLabel;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLUserFollowTableViewCell

- (void)setUser:(MRSLUser *)user {
    if (_user != user) {
        _user = user;

        self.profileImageView.user = _user;
        self.userFullNameLabel.text = _user.fullName;
        self.usernameLabel.text = _user.username;
    }
    self.followButton.user = _user;
}

@end
