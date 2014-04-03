//
//  MRSLActivityCollectionViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityCollectionViewCell.h"

#import "MRSLActivity.h"
#import "MRSLMorselImageView.h"
#import "MRSLProfileImageView.h"

@interface MRSLActivityCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet MRSLMorselImageView *morselImageView;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *creatorProfileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *actionIconImageView;

@end

@implementation MRSLActivityCollectionViewCell

- (void)setActivity:(MRSLActivity *)activity {
    if (_activity != activity) {
        _activity = activity;

        self.descriptionLabel.text = [activity message];
        [self.descriptionLabel sizeToFit];
        [self.descriptionLabel setWidth:160.0f];
        self.timeAgoLabel.text = [NSString stringWithFormat:@"%@", activity.creationDate];
        self.morselImageView.morsel = activity.morsel;
        self.creatorProfileImageView.user = activity.creator;

        if ([activity.actionType isEqualToString:@"Like"]) {
            [self.actionIconImageView setImage:[UIImage imageNamed:@"icon-like-dark"]];
        } else if([activity.actionType isEqualToString:@"Comment"]) {
            [self.actionIconImageView setImage:[UIImage imageNamed:@"icon-comment-dark"]];
        } else {
            [self.actionIconImageView setImage:nil];
        }
    }
}

@end
