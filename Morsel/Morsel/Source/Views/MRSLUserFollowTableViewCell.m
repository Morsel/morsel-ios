//
//  MRSLUserFollowTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserFollowTableViewCell.h"

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLUserFollowTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *followButton;
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
    [self setFollowButtonState];
}

#pragma mark - Private Methods

- (void)setFollowButtonState {
    self.followButton.hidden = [_user isCurrentUser];
    [self.followButton setBackgroundColor:(_user.followingValue) ? [UIColor morselRed] : [UIColor morselGreen]];
    [self.followButton setTitle:(_user.followingValue) ? @"Unfollow" : @"Follow"
                       forState:UIControlStateNormal];
}

#pragma mark - Action Methods

- (IBAction)toggleFollow {
    _followButton.enabled = NO;

    [[MRSLEventManager sharedManager] track:@"Tapped Follow"
                                 properties:@{@"view": @"follow_list",
                                              @"user_id": _user.userID}];

    [_user setFollowingValue:!_user.followingValue];
    [self setFollowButtonState];

    [_appDelegate.apiService followUser:_user
                           shouldFollow:_user.followingValue
                              didFollow:^(BOOL doesFollow) {
                                  _followButton.enabled = YES;
                              } failure:^(NSError *error) {
                                  _followButton.enabled = YES;
                                  [_user setFollowingValue:!_user.followingValue];
                                  [_user setFollower_countValue:_user.follower_countValue - 1];
                                  [self setFollowButtonState];
                              }];
}

@end
