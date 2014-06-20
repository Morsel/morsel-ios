//
//  MRSLActivityTableViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityTableViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLActivity.h"
#import "MRSLUser.h"

@interface MRSLActivityTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *senderProfileImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *receiverProfileImageView;

@end

@implementation MRSLActivityTableViewCell

- (void)setActivity:(MRSLActivity *)activity {
    self.descriptionLabel.text = [activity message];
    self.timeAgoLabel.text = [activity.creationDate timeAgo];
    self.senderProfileImageView.user = activity.creator;

    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel setWidth:160.f];

    if ([activity hasUserSubject]) {
        self.itemImageView.hidden = YES;
        self.receiverProfileImageView.hidden = NO;

        self.receiverProfileImageView.user = activity.userSubject;
    } else {
        self.itemImageView.hidden = NO;
        self.itemImageView.item = activity.itemSubject;
        self.receiverProfileImageView.hidden = YES;
        self.receiverProfileImageView.user = nil;
    }
}

@end
