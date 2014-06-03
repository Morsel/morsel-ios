//
//  MRSLUserFollowTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserFollowTableViewCell.h"

#import "MRSLAPIService+Follow.h"

#import "MRSLFollowButton.h"
#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLUserFollowTableViewCell ()

@property (weak, nonatomic) IBOutlet MRSLFollowButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLUserFollowTableViewCell

- (void)setUser:(MRSLUser *)user {
    if (_user != user) {
        _user = user;

        self.profileImageView.user = _user;
        self.userNameLabel.text = _user.fullName;
    }
    self.followButton.user = _user;
}

@end
