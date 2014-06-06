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

        if ([[activity.actionType lowercaseString] isEqualToString:@"follow"]) {
            self.itemImageView.hidden = YES;
            self.subjectProfileImageView.hidden = NO;

            MRSLUser *subjectUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                            withValue:_activity.subjectID];
            self.subjectProfileImageView.user = subjectUser;
        } else {
            self.subjectProfileImageView.user = nil;
        }
    }
}

- (void)reset {
    self.itemImageView.hidden = NO;
    self.subjectProfileImageView.hidden = YES;
}

@end
