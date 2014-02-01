//
//  MorselDetailCommentsViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselDetailCommentsViewController.h"

#import "CommentTableViewCell.h"
#import "ModelController.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"

@interface MorselDetailCommentsViewController ()
    <UITableViewDataSource,
     UITableViewDelegate,
     NSFetchedResultsControllerDelegate>

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
                                                                   inContext:[ModelController sharedController].defaultContext];
            
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

- (CommentTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    CommentTableViewCell *commentCell = [self.commentsTableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    commentCell.comment = comment;
    commentCell.pipeView.hidden = (indexPath.row == _commentCount - 1);
    
    return commentCell;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu comments.", (unsigned long)[[controller fetchedObjects] count]);
    
    if ([self.delegate respondsToSelector:@selector(morselDetailCommentsViewControllerDidUpdateWithAmountOfComments:)]) {
        [self.delegate morselDetailCommentsViewControllerDidUpdateWithAmountOfComments:[[controller fetchedObjects] count]];
    }
    
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    
    if (fetchError) {
        DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
    }
    
    [self.commentsTableView reloadData];
}

@end
