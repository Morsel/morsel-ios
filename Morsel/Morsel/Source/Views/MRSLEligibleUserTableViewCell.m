//
//  MRSLEligibleUserTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 10/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLEligibleUserTableViewCell.h"

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLEligibleUserTableViewCell ()

@property (weak, nonatomic) MRSLUser *user;
@property (weak, nonatomic) MRSLMorsel *morsel;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkView;
@property (weak, nonatomic) IBOutlet UILabel *userFullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation MRSLEligibleUserTableViewCell

- (void)setUser:(MRSLUser *)user
      andMorsel:(MRSLMorsel *)morsel {
    if (self.user != user) {
        self.user = user;
        self.profileImageView.user = _user;
        self.userFullNameLabel.text = _user.fullName;
        self.usernameLabel.text = _user.username;
    }
    self.morsel = morsel;

    [self.checkmarkView setImage:[UIImage imageNamed:(_user.taggedValue) ? @"icon-circle-check-green" : @"icon-circle-check-gray"]];
}

@end
