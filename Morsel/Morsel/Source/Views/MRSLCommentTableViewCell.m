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
<ProfileImageViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentBodyLabel;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLCommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [_profileImageView addCornersWithRadius:20.f];
}

- (void)setComment:(MRSLComment *)comment {
    [self reset];

    _comment = comment;
    if (_comment) {
        _profileImageView.user = _comment.creator;
        _profileImageView.delegate = self;
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

#pragma mark - ProfileImageViewDelegate

- (void)profileImageViewDidSelectUser:(MRSLUser *)user {
    if ([self.delegate respondsToSelector:@selector(commentTableViewCellDidSelectUser:)]) {
        [self.delegate commentTableViewCellDidSelectUser:user];
    }
}

@end
