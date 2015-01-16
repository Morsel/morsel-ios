//
//  MRSLActivityTableViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityTableViewCell.h"

#import <DateTools/NSDate+DateTools.h>

#import "MRSLItemImageView.h"
#import "MRSLProfileImageView.h"

#import "MRSLActivity.h"
#import "MRSLMorsel.h"
#import "MRSLNotification.h"
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
    _activity = activity;

    self.descriptionLabel.text = [activity message];
    self.timeAgoLabel.text = [activity.creationDate timeAgoSinceNow];
    self.senderProfileImageView.user = activity.creator;

    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel setWidth:160.f];

    if ([activity hasPlaceSubject]) {
        self.itemImageView.hidden = YES;
        self.receiverProfileImageView.hidden = YES;
    } else if ([activity hasUserSubject]) {
        self.itemImageView.hidden = YES;
        self.receiverProfileImageView.hidden = NO;

        self.receiverProfileImageView.user = activity.userSubject;
    } else if ([activity hasMorselSubject]) {
        self.itemImageView.hidden = NO;
        self.itemImageView.item = [activity.morselSubject coverItem];
        self.receiverProfileImageView.hidden = YES;
        self.receiverProfileImageView.user = nil;
    } else {
        self.itemImageView.hidden = NO;
        self.itemImageView.item = activity.itemSubject;
        self.receiverProfileImageView.hidden = YES;
        self.receiverProfileImageView.user = nil;
    }
}

- (UIColor *)defaultBackgroundColor {
    if (self.activity.notification) {
        return (self.activity.notification.readValue) ? [UIColor morselDefaultCellBackgroundColor] : [UIColor morselPrimaryLightest];
    }
    return [UIColor morselDefaultCellBackgroundColor];
}

@end
