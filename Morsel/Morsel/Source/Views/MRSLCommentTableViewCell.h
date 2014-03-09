//
//  CommentTableViewCell.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLComment, MRSLUser;

@protocol CommentTableViewCellDelegate <NSObject>

@optional
- (void)commentTableViewCellDidSelectUser:(MRSLUser *)user;

@end

@interface MRSLCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) id <CommentTableViewCellDelegate> delegate;

@property (strong, nonatomic) MRSLComment *comment;
@property (weak, nonatomic) IBOutlet UIView *pipeView;

@end
