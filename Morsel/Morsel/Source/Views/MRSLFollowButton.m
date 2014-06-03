//
//  MRSLFollowButton.m
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFollowButton.h"

#import "MRSLAPIService+Follow.h"

#import "MRSLPlace.h"
#import "MRSLUser.h"

@implementation MRSLFollowButton

- (void)setUp {
    [self addTarget:self
             action:@selector(toggleFollow)
   forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUser:(MRSLUser *)user {
    if (_user != user) {
        _user = user;
        [self setFollowState];
    }
}

- (void)setPlace:(MRSLPlace *)place {
    if (_place != place) {
        _place = place;
        [self setFollowState];
    }
}

- (void)setFollowState {
    [self setBackgroundColor:(_user.followingValue || _place.followingValue) ? [UIColor lightGrayColor] : [UIColor morselGreen]];
    [self setTitle:(_user.followingValue || _place.followingValue) ? @"Following" : @"Follow"
          forState:UIControlStateNormal];
}

- (void)toggleFollow {
    __weak __typeof(self) weakSelf = self;
    if (_user) {
        [[MRSLEventManager sharedManager] track:@"Tapped Follow"
                                     properties:@{@"view": @"profile",
                                                  @"user_id": _user.userID}];

        [_user setFollowingValue:!_user.followingValue];
        [self setFollowState];

        [_appDelegate.apiService followUser:_user
                               shouldFollow:_user.followingValue
                                  didFollow:^(BOOL doesFollow) {
                                      weakSelf.enabled = YES;
                                  } failure:^(NSError *error) {
                                      weakSelf.enabled = YES;
                                      [weakSelf.user setFollowingValue:!weakSelf.user.followingValue];
                                      [weakSelf.user setFollower_countValue:weakSelf.user.follower_countValue - 1];
                                      [weakSelf setFollowState];
                                  }];
    }
    if (_place) {
        [_place setFollowingValue:!_place.followingValue];
        [self setFollowState];

        [_appDelegate.apiService followPlace:_place
                                shouldFollow:_place.followingValue
                                   didFollow:^(BOOL doesFollow) {
                                       weakSelf.enabled = YES;
                                   } failure:^(NSError *error) {
                                       weakSelf.enabled = YES;
                                       [weakSelf.place setFollowingValue:!weakSelf.place.followingValue];
                                       [weakSelf.place setFollower_countValue:weakSelf.place.follower_countValue - 1];
                                       [weakSelf setFollowState];
                                   }];
    }
}

@end