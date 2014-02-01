//
//  CommentTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "CommentTableViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "ProfileImageView.h"

#import "MRSLComment.h"
#import "MRSLUser.h"

@interface CommentTableViewCell  ()

@property (nonatomic, weak) IBOutlet UILabel *timeAgoLabel;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentBodyLabel;
@property (nonatomic, weak) IBOutlet ProfileImageView *profileImageView;

@end

@implementation CommentTableViewCell

- (void)setComment:(MRSLComment *)comment {
    if (_comment != comment) {
        _comment = comment;
        if (_comment) {
            [_profileImageView addCornersWithRadius:20.f];
            
            _profileImageView.user = _comment.user;
            _userNameLabel.text = _comment.user.fullName;
            _commentBodyLabel.text = _comment.text;
            _timeAgoLabel.text = [_comment.creationDate dateTimeAgo];
        }
    }
}

@end
