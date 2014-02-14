//
//  MorselDetailCommentsViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselDetailCommentsViewController.h"

#import "CommentTableViewCell.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"

static const CGFloat MRSLDefaultCommentLabelHeight = 14.f;
static const CGFloat MRSLDefaultCommentLabelWidth = 192.f;

@interface MorselDetailCommentsViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate,
CommentTableViewCellDelegate>

@property (nonatomic) int commentCount;

@property (nonatomic, weak) IBOutlet UITableView *commentsTableView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MorselDetailCommentsViewController

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        if (_morsel && !_fetchedResultsController) {
            NSPredicate *commentsForMorselPredicate = [NSPredicate predicateWithFormat:@"morsel.morselID == %i", [_morsel.morselID intValue]];

            self.fetchedResultsController = [MRSLComment MR_fetchAllSortedBy:@"creationDate"
                                                                   ascending:YES
                                                               withPredicate:commentsForMorselPredicate
                                                                     groupBy:nil
                                                                    delegate:self
                                                                   inContext:[NSManagedObjectContext MR_defaultContext]];

            [self.commentsTableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    self.commentCount = [sectionInfo numberOfObjects];

    return _commentCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];
    CGSize bodySize = [comment.commentDescription sizeWithFont:[UIFont helveticaLightObliqueFontOfSize:12.f]
                                             constrainedToSize:CGSizeMake(MRSLDefaultCommentLabelWidth, CGFLOAT_MAX)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat defaultCellSize = 110.f;

    if (bodySize.height > MRSLDefaultCommentLabelHeight) {
        defaultCellSize = defaultCellSize + (bodySize.height - MRSLDefaultCommentLabelHeight);
    }
    return defaultCellSize;
}

- (CommentTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];

    CommentTableViewCell *commentCell = [self.commentsTableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    commentCell.comment = comment;
    commentCell.delegate = self;
    commentCell.pipeView.hidden = (indexPath.row == _commentCount - 1);

    return commentCell;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSArray *comments = [controller fetchedObjects];

    if ([comments count] > 0) {
        DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu comments.", (unsigned long)[comments count]);
        if ([self.delegate respondsToSelector:@selector(morselDetailCommentsViewControllerDidUpdateWithAmountOfComments:)]) {
            [self.delegate morselDetailCommentsViewControllerDidUpdateWithAmountOfComments:[comments count]];
        }

        NSError *fetchError = nil;
        [_fetchedResultsController performFetch:&fetchError];

        if (fetchError) {
            DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
        }
        
        [self.commentsTableView reloadData];
    }
}

#pragma mark - CommentTableViewCellDelegate

- (void)commentTableViewCellDidSelectUser:(MRSLUser *)user {
    if ([self.delegate respondsToSelector:@selector(morselDetailCommentsViewControllerDidSelectUser:)]) {
        [self.delegate morselDetailCommentsViewControllerDidSelectUser:user];
    }
}

@end
