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
    [super setUp];
    [self addTarget:self
             action:@selector(toggleFollow)
   forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUser:(MRSLUser *)user {
    _user = user;
    [self setFollowState];
}

- (void)setPlace:(MRSLPlace *)place {
    _place = place;
    [self setFollowState];
}

- (void)setFollowState {
    if (![_user isCurrentUser]) {
        self.hidden = NO;
        [self setBackgroundColor:(_user.followingValue || _place.followingValue) ? [UIColor lightGrayColor] : [UIColor morselSecondary]];
        CGFloat maxX = CGRectGetMaxX(self.frame);
        [self setTitle:(_user.followingValue || _place.followingValue) ? @"Following" : @"Follow"
              forState:UIControlStateNormal];
        [self setWidth:84.0f];
        [self setHeight:32.0f];
        [self setX:maxX - [self getWidth]];
    } else {
        self.hidden = YES;
    }
}

- (void)toggleFollow {
    if ([MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    if (_user) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Follow",
                                                  @"user_id": _user.userID}];

        [_user setFollowingValue:!_user.followingValue];
        [self setFollowState];

        [_appDelegate.apiService followUser:_user
                               shouldFollow:_user.followingValue
                                  didFollow:^(BOOL doesFollow) {
                                      if (weakSelf.user.followingValue) [MRSLEventManager sharedManager].users_followed++;
                                      weakSelf.enabled = YES;
                                  } failure:^(NSError *error) {
                                      weakSelf.enabled = YES;
                                      [weakSelf.user setFollowingValue:!weakSelf.user.followingValue];
                                      [weakSelf.user setFollower_countValue:weakSelf.user.follower_countValue - 1];
                                      [weakSelf setFollowState];
                                  }];
    }
    if (_place) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Follow",
                                                  @"place_id": _place.placeID}];

        [_place setFollowingValue:!_place.followingValue];
        [self setFollowState];

        [_appDelegate.apiService followPlace:_place
                                shouldFollow:_place.followingValue
                                   didFollow:^(BOOL doesFollow) {
                                       if (weakSelf.place.followingValue) [MRSLEventManager sharedManager].places_followed++;
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
