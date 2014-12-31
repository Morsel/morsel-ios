//
//  MRSLModalCommentsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalCommentsViewController.h"

#import "MRSLAPIService+Comment.h"

#import "MRSLCommentTableViewCell.h"
#import "MRSLPlaceholderTextView.h"
#import "MRSLProfileViewController.h"
#import "MRSLTableView.h"
#import "MRSLTableViewDataSource.h"

#import "MRSLComment.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

static const CGFloat MRSLDefaultCommentLabelHeight = 14.f;
static const CGFloat MRSLDefaultCommentLabelPadding = 128.f;

@interface MRSLBaseRemoteDataSourceViewController (Private)

- (void)populateContent;

@end

@interface MRSLModalCommentsViewController ()
<MRSLTableViewDataSourceDelegate>

@property (nonatomic) BOOL previousCommentsAvailable;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet UIView *commentInputView;
@property (weak, nonatomic) IBOutlet MRSLPlaceholderTextView *commentInputTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;

@end

@implementation MRSLModalCommentsViewController

- (void)viewDidLoad {
    self.disablePagination = YES;

    [super viewDidLoad];

    self.mp_eventView = @"comments";
    self.emptyStateString = @"No comments yet. Add one below.";
    self.commentInputTextView.placeholder = @"Add comment...";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [_appDelegate.apiService getComments:strongSelf.item
                                        page:page
                                       count:nil
                                     success:^(NSArray *responseArray) {
                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                         if ([page intValue] == 1) {
                                             [weakSelf scrollTableViewToBottom];
                                         }
                                     } failure:^(NSError *error) {
                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                     }];
    };
    [self scrollTableViewToBottom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                      animated:YES];
        self.selectedIndexPath = nil;
    }
}

#pragma mark - Private Methods

- (void)scrollTableViewToBottom {
    if (self.tableView.contentSize.height > [self.tableView getHeight]) {
        CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
        [self.tableView setContentOffset:bottomOffset
                                animated:NO];
    }
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%i_commentIDs", _item.itemIDValue];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLComment MR_fetchAllSortedBy:@"creationDate"
                                   ascending:YES
                               withPredicate:[NSPredicate predicateWithFormat:@"commentID IN %@", self.objectIDs]
                                     groupBy:nil
                                    delegate:self
                                   inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                                  configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                                      if (_previousCommentsAvailable && indexPath.row == 0) {
                                                                          UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:(self.loadingMore) ? MRSLStoryboardRUIDPreviousLoadingKey :
                                                                                                            MRSLStoryboardRUIDPreviousCommentCellKey];
                                                                          return tableViewCell;
                                                                      }
                                                                      NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - ((self.previousCommentsAvailable) ? 1 : 0))
                                                                                                                          inSection:indexPath.section];
                                                                      MRSLComment *comment = [self.dataSource objectAtIndexPath:adjustedIndexPath];
                                                                      MRSLCommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDCommentCellKey];
                                                                      commentCell.comment = comment;
                                                                      commentCell.pipeView.hidden = (indexPath.row == count - 1);
                                                                      return commentCell;
                                                                  }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

- (void)populateContent {
    [super populateContent];
    self.previousCommentsAvailable = (_item.comment_countValue != [self.dataSource count]);
}

#pragma mark - Action Methods

- (IBAction)addComment {
    if ([MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    if (_item) {
        if (_commentInputTextView.text.length > 0) {
            [_commentInputTextView resignFirstResponder];
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Add Comment",
                                                      @"_view": self.mp_eventView,
                                                      @"morsel_id": NSNullIfNil(_item.morsel.morselID),
                                                      @"item_id": NSNullIfNil(_item.itemID),
                                                      @"comment_count": NSNullIfNil(_item.comment_count)}];
            __weak __typeof (self) weakSelf = self;
            [_appDelegate.apiService addCommentWithDescription:_commentInputTextView.text
                                                      toMorsel:_item
                                                       success:^(id responseObject) {
                                                           [MRSLEventManager sharedManager].comments_added++;
                                                           if (responseObject && weakSelf) {
                                                               weakSelf.objectIDs = [weakSelf.objectIDs arrayByAddingObject:[(MRSLComment *)responseObject commentID]];
                                                               [weakSelf.dataSource addObject:responseObject];
                                                               [weakSelf refreshLocalContent];
                                                               [weakSelf scrollTableViewToBottom];
                                                           }
                                                       } failure:nil];
            _commentInputTextView.text = nil;
        } else {
            [UIAlertView showAlertViewForErrorString:@"Please add some text to submit a comment!"
                                            delegate:nil];
        }
    }
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.toolbarBottomLayoutGuide.constant = keyboardSize.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.35f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.toolbarBottomLayoutGuide.constant = 0.f;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - MRSLTableViewDataSource Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = ([self.dataSource count] + ((_previousCommentsAvailable) ? 1 : 0));
    return count;
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_previousCommentsAvailable && indexPath.row == 0) return 44;
    NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - ((self.previousCommentsAvailable) ? 1 : 0))
                                                        inSection:indexPath.section];
    MRSLComment *comment = [self.dataSource objectAtIndexPath:adjustedIndexPath];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect bodyRect = [comment.commentDescription boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - MRSLDefaultCommentLabelPadding, CGFLOAT_MAX)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName: [UIFont primaryLightFontOfSize:12.f], NSParagraphStyleAttributeName: paragraphStyle}
                                                               context:nil];
    CGFloat defaultCellSize = 70.f;

    if (bodyRect.size.height > MRSLDefaultCommentLabelHeight) {
        defaultCellSize = defaultCellSize + (bodyRect.size.height - MRSLDefaultCommentLabelHeight);
    }
    return defaultCellSize;
}

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    if (_previousCommentsAvailable && indexPath.row == 0) {
        if (self.loadingMore) return;
        [super loadNextPage];
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
    } else {
        NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - ((self.previousCommentsAvailable) ? 1 : 0))
                                                            inSection:indexPath.section];
        MRSLComment *comment = [self.dataSource objectAtIndexPath:adjustedIndexPath];
        MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
        profileVC.user = comment.creator;
        [self.navigationController pushViewController:profileVC
                                             animated:YES];
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self addComment];
        return NO;
    } else {
        return YES;
    }

    return YES;
}

@end
