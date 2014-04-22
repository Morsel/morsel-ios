//
//  CommentTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLCommentTableViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLProfileImageView.h"

#import "MRSLComment.h"
#import "MRSLUser.h"

@interface MRSLCommentTableViewCell  ()

@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentBodyLabel;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLCommentTableViewCell

- (void)setComment:(MRSLComment *)comment {
    [self reset];

    _comment = comment;
    if (_comment) {
        _profileImageView.user = _comment.creator;
        [_profileImageView allowToLaunchProfile];
        _userNameLabel.text = _comment.creator.fullName;
        _commentBodyLabel.text = _comment.commentDescription;
        _timeAgoLabel.text = [_comment.creationDate timeAgo];

        CGSize bodySize = [_comment.commentDescription sizeWithFont:_commentBodyLabel.font
                                                  constrainedToSize:CGSizeMake(_commentBodyLabel.frame.size.width, CGFLOAT_MAX)
                                                      lineBreakMode:NSLineBreakByWordWrapping];

        [_commentBodyLabel setHeight:ceilf(bodySize.height)];
    }
}

- (void)reset {
    self.userNameLabel.text = nil;
    self.commentBodyLabel.text = nil;
    self.timeAgoLabel.text = nil;
    self.delegate = nil;
    self.profileImageView.user = nil;
}

@end
