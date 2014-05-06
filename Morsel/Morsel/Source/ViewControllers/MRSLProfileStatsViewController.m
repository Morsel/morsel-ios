//
//  MRSLProfileStatsViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileStatsViewController.h"

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLProfileStatsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UILabel *userHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLProfileStatsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    if (_user) [self refreshProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.followButton.hidden = [_user isCurrentUser];
}

- (void)setUser:(MRSLUser *)user {
    _user = user;
    [self populateUserContent];
    [self refreshProfile];
}

#pragma mark - Private Methods

- (void)refreshProfile {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getUserProfile:_user
                                    success:^(id responseObject) {
                                        if (weakSelf) [weakSelf populateUserContent];
                                    } failure:nil];
}

- (void)populateUserContent {
    self.profileImageView.user = _user;
    self.userNameLabel.text = _user.fullName;
    self.userBioLabel.text = _user.bio;
    self.userHandleLabel.text = [NSString stringWithFormat:@"%@", _user.username];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.liked_items_countValue];
    self.morselCountLabel.text = [NSString stringWithFormat:@"%i", _user.morsel_countValue];
    self.followersCountLabel.text = [NSString stringWithFormat:@"%i", _user.follower_countValue];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%i", _user.followed_users_countValue];
    [self setFollowButtonState];
}

- (void)setFollowButtonState {
    [self.followButton setBackgroundColor:(_user.followingValue) ? [UIColor morselRed] : [UIColor morselGreen]];
    [self.followButton setTitle:(_user.followingValue) ? @"Unfollow" : @"Follow"
                       forState:UIControlStateNormal];
}

#pragma mark - Notification Methods

- (void)updateContent:(NSNotification *)notification {
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];

    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if ([managedObject isKindOfClass:[MRSLUser class]]) {
            MRSLUser *user = (MRSLUser *)managedObject;
            if (user.userIDValue == weakSelf.user.userIDValue) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf populateUserContent];
                });
                *stop = YES;
            }
        }
    }];
}

#pragma mark - Action Methods

- (IBAction)toggleFollow {
    _followButton.enabled = NO;

    [[MRSLEventManager sharedManager] track:@"Tapped Follow"
                                 properties:@{@"view": @"profile",
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

- (IBAction)displayLiked {
    if ([self.delegate respondsToSelector:@selector(profileStatsViewControllerDidSelectLiked)]) {
        [self.delegate profileStatsViewControllerDidSelectLiked];
    }
}

- (IBAction)displayFollowers {
    if ([self.delegate respondsToSelector:@selector(profileStatsViewControllerDidSelectFollowers)]) {
        [self.delegate profileStatsViewControllerDidSelectFollowers];
    }
}

- (IBAction)displayFollowing {
    if ([self.delegate respondsToSelector:@selector(profileStatsViewControllerDidSelectFollowing)]) {
        [self.delegate profileStatsViewControllerDidSelectFollowing];
    }
}

@end
