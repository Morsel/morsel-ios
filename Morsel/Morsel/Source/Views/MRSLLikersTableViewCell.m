//
//  MRSLLikersTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLLikersTableViewCell.h"

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLLikersTableViewCell ()

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation MRSLLikersTableViewCell

- (void)setUser:(MRSLUser *)user {
    if (_user != user) {
        _user = user;

        self.profileImageView.user = _user;
        [_profileImageView allowToLaunchProfile];
        self.userNameLabel.text = [_user fullName];
    }
}


@end
