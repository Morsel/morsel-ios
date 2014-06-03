//
//  MRSLActivityCollectionViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityCollectionViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLActivity.h"
#import "MRSLUser.h"

@interface MRSLActivityCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *creatorProfileImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *subjectProfileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *actionIconImageView;

@end

@implementation MRSLActivityCollectionViewCell

- (void)setActivity:(MRSLActivity *)activity {
    if (_activity != activity) {
        _activity = activity;

        [self reset];

        self.descriptionLabel.text = [activity message];
        self.timeAgoLabel.text = [activity.creationDate timeAgo];
        self.itemImageView.item = activity.item;
        self.creatorProfileImageView.user = activity.creator;

        [self.descriptionLabel sizeToFit];
        [self.descriptionLabel setWidth:160.f];

        if ([[activity.actionType lowercaseString] isEqualToString:@"like"]) {
            [self.actionIconImageView setImage:[UIImage imageNamed:@"icon-like-dark"]];
        } else if ([[activity.actionType lowercaseString] isEqualToString:@"comment"]) {
            [self.actionIconImageView setImage:[UIImage imageNamed:@"icon-comment-dark"]];
        } else if ([[activity.actionType lowercaseString] isEqualToString:@"follow"]) {
            self.itemImageView.hidden = YES;
            self.subjectProfileImageView.hidden = NO;
            [self.actionIconImageView setImage:nil];

            MRSLUser *subjectUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                            withValue:_activity.subjectID];
            self.subjectProfileImageView.user = subjectUser;
        } else {
            self.subjectProfileImageView.user = nil;
            [self.actionIconImageView setImage:nil];
        }
    }
}

- (void)reset {
    self.itemImageView.hidden = NO;
    self.subjectProfileImageView.hidden = YES;
}

@end
