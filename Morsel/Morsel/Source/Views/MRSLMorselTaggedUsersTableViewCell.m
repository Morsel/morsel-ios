//
//  MRSLMorselTaggedUsersTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 10/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselTaggedUsersTableViewCell.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLProfileImageView.h"
#import "MRSLPrimaryLightLabel.h"

#import "MRSLUser.h"

@interface MRSLMorselTaggedUsersTableViewCell ()

@property (nonatomic) BOOL loading;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *tagStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *usersContainerView;

@property (strong, nonatomic) NSArray *taggedUserIDs;

@end

@implementation MRSLMorselTaggedUsersTableViewCell

#pragma mark - Instance Methods

- (void)setMorsel:(MRSLMorsel *)morsel {
    _morsel = morsel;
    [self refreshContent];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setSelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectedState:selected];
}

- (void)setSelectedState:(BOOL)selected {
    self.arrowImageView.image = [UIImage imageNamed:(selected) ? @"icon-arrow-accessory-white" : @"icon-arrow-accessory-red"];
}

#pragma mark - Private Methods

- (void)refreshContent {
    if (_loading) return;
    self.loading = YES;
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService getTaggedUsersForMorsel:_morsel
                                                page:nil
                                               count:nil
                                             success:^(NSArray *responseArray) {
                                                 if (weakSelf) {
                                                     weakSelf.taggedUserIDs = responseArray;
                                                     weakSelf.loading = NO;
                                                     [weakSelf populateContent];
                                                 }
                                             } failure:^(NSError *error) {
                                                 if (weakSelf) {
                                                     weakSelf.loading = NO;
                                                 }
                                             }];
}

- (void)populateContent {
    for (UIView *subview in self.usersContainerView.subviews) {
        [subview removeFromSuperview];
    }
    if ([_taggedUserIDs count] == 0) {
        self.tagStatusLabel.hidden = NO;
        self.tagStatusLabel.text = @"None";
        self.tagStatusLabel.font = [UIFont primaryLightItalicFontOfSize:self.tagStatusLabel.font.pointSize];
    } else {
        self.tagStatusLabel.hidden = YES;
        self.tagStatusLabel.font = [UIFont primaryLightFontOfSize:self.tagStatusLabel.font.pointSize];
        int userCount = 0;
        int userSpacing = 0.f;
        for (NSNumber *userID in _taggedUserIDs) {
            MRSLUser *taggedUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID withValue:userID];
            if (taggedUser) {
                if (userCount >= 4) {
                    MRSLPrimaryLightLabel *remainingTagUsersLabel = [[MRSLPrimaryLightLabel alloc] initWithFrame:CGRectMake(userSpacing, 0.f, 40.f, 40.f)];
                    remainingTagUsersLabel.textAlignment = NSTextAlignmentCenter;
                    remainingTagUsersLabel.textColor = [UIColor whiteColor];
                    remainingTagUsersLabel.backgroundColor = [UIColor morselPrimary];
                    [remainingTagUsersLabel setRoundedCornerRadius:20.f];
                    remainingTagUsersLabel.text = [NSString stringWithFormat:@"+%i", (int)([_taggedUserIDs count] - userCount)];
                    [self.usersContainerView addSubview:remainingTagUsersLabel];
                    break;
                } else {
                    MRSLProfileImageView *profileImageView = [[MRSLProfileImageView alloc] initWithFrame:CGRectMake(userSpacing, 0.f, 40.f, 40.f)];
                    profileImageView.user = taggedUser;
                    [self.usersContainerView addSubview:profileImageView];
                    userSpacing += 45.f;
                    userCount ++;
                }
            }
        }
    }
}

@end
