//
//  MRSLPlaceUserCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceUserCollectionViewCell.h"

#import "MRSLProfileImageView.h"

#import "MRSLUser.h"

@interface MRSLPlaceUserCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;

@end

@implementation MRSLPlaceUserCollectionViewCell

- (void)setUser:(MRSLUser *)user {
    _user = user;
    self.profileImageView.user = _user;
    self.nameLabel.text = [_user fullName];
    self.positionLabel.text = [_user title];
}

@end
