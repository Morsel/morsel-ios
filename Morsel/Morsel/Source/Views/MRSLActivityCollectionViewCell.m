//
//  MRSLActivityCollectionViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityCollectionViewCell.h"

#import <DateTools/NSDate+DateTools.h>

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
        self.timeAgoLabel.text = [activity.creationDate timeAgoSinceNow];
        self.creatorProfileImageView.user = activity.creator;

        [self.descriptionLabel sizeToFit];
        [self.descriptionLabel setWidth:160.f];

        if ([activity hasPlaceSubject]) {
            self.itemImageView.hidden = YES;
            self.subjectProfileImageView.hidden = YES;
        } else if ([activity hasUserSubject]) {
            self.itemImageView.hidden = YES;
            self.subjectProfileImageView.hidden = NO;

            self.subjectProfileImageView.user = activity.userSubject;
        } else {
            self.subjectProfileImageView.user = nil;
            self.itemImageView.item = activity.itemSubject;
        }
    }
}

- (void)reset {
    self.itemImageView.hidden = NO;
    self.subjectProfileImageView.hidden = YES;
}

@end
