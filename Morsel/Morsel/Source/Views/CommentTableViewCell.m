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
    <ProfileImageViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *timeAgoLabel;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentBodyLabel;
@property (nonatomic, weak) IBOutlet ProfileImageView *profileImageView;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_profileImageView addCornersWithRadius:20.f];
}

- (void)setComment:(MRSLComment *)comment {
    if (_comment != comment) {
        [self reset];
        
        _comment = comment;
        if (_comment) {
            _profileImageView.user = _comment.user;
            _profileImageView.delegate = self;
            _userNameLabel.text = _comment.user.fullName;
            _commentBodyLabel.text = _comment.text;
            _timeAgoLabel.text = [_comment.creationDate dateTimeAgo];
            
            CGSize bodySize = [_comment.text sizeWithFont:_commentBodyLabel.font
                                        constrainedToSize:CGSizeMake(_commentBodyLabel.frame.size.width, CGFLOAT_MAX)
                                            lineBreakMode:NSLineBreakByWordWrapping];
            
            [_commentBodyLabel setHeight:ceilf(bodySize.height)];
        }
    }
}

- (void)reset {
    self.profileImageView.user = nil;
    self.userNameLabel.text = nil;
    self.commentBodyLabel.text = nil;
    self.timeAgoLabel.text = nil;
    self.delegate = nil;
}

#pragma mark - ProfileImageViewDelegate

- (void)profileImageViewDidSelectUser:(MRSLUser *)user {
    if ([self.delegate respondsToSelector:@selector(commentTableViewCellDidSelectUser:)]) {
        [self.delegate commentTableViewCellDidSelectUser:user];
    }
}

@end
