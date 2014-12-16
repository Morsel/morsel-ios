//
//  CommentTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLCommentTableViewCell.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLAPIService+Comment.h"

#import "MRSLPrimaryLabel.h"
#import "MRSLProfileImageView.h"

#import "MRSLComment.h"
#import "MRSLUser.h"

@interface MRSLCommentTableViewCell  ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet MRSLPrimaryLabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentBodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLCommentTableViewCell

#pragma mark - Instance Methods

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_comment) {
        [self reset];
        _profileImageView.user = _comment.creator;
        _userNameLabel.text = _comment.creator.fullName;
        [_userNameLabel setOblique:[_comment.creator hasEmptyName]];
        _commentBodyLabel.text = _comment.commentDescription;
        _timeAgoLabel.text = [_comment.creationDate timeAgo];

        self.deleteButton.hidden = ![_comment deleteableByUser:[MRSLUser currentUser]];
    }
}

#pragma mark - Action Methods

- (IBAction)deleteComment {
    [UIAlertView showAlertViewWithTitle:@"Delete Comment"
                                message:@"Are you sure you want to delete this comment?"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Yes", nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [_appDelegate.apiService deleteComment:self.comment
                                       success:nil
                                       failure:nil];
    }
}

#pragma mark - Reset

- (void)reset {
    self.userNameLabel.text = nil;
    self.commentBodyLabel.text = nil;
    self.timeAgoLabel.text = nil;
    self.delegate = nil;
    self.profileImageView.user = nil;
}

@end
