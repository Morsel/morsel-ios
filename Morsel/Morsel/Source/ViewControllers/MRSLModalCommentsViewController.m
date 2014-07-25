//
//  MRSLModalCommentsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalCommentsViewController.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLAPIService+Comment.h"

#import "MRSLCommentTableViewCell.h"
#import "MRSLProfileViewController.h"
#import "MRSLTableView.h"

#import "MRSLComment.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"

static const CGFloat MRSLDefaultCommentLabelHeight = 14.f;
static const CGFloat MRSLDefaultCommentLabelWidth = 192.f;

@interface MRSLModalCommentsViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL previousCommentsAvailable;
@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet MRSLTableView *commentsTableView;
@property (weak, nonatomic) IBOutlet UIView *commentInputView;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *commentInputTextView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *commentIDs;

@end

@implementation MRSLModalCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.commentIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%i_commentIDs", _item.itemIDValue]] ?: [NSMutableArray array];
    self.comments = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.commentsTableView addSubview:_refreshControl];
    self.commentsTableView.alwaysBounceVertical = YES;
    [self.commentsTableView setEmptyStateTitle:@"No comments yet. Add one below."];

    self.commentInputTextView.placeholder = @"Write a comment...";
    self.commentInputTextView.placeholderColor = [UIColor morselLightContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_fetchedResultsController) return;

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Private Methods

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.commentsTableView toggleLoading:loading];
}

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLComment MR_fetchAllSortedBy:@"creationDate"
                                                           ascending:YES
                                                       withPredicate:[NSPredicate predicateWithFormat:@"commentID IN %@", _commentIDs]
                                                             groupBy:nil
                                                            delegate:self
                                                           inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.comments = [_fetchedResultsController fetchedObjects];
    self.previousCommentsAvailable = (_item.comment_countValue != [_comments count]);
    [self.commentsTableView reloadData];
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getComments:_item
                               withMaxID:nil
                               orSinceID:nil
                                andCount:@(10)
                                 success:^(NSArray *responseArray) {
                                     if (weakSelf) {
                                         [weakSelf.refreshControl endRefreshing];
                                         weakSelf.commentIDs = [responseArray mutableCopy];
                                         [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                   forKey:[NSString stringWithFormat:@"%i_commentIDs", _item.itemIDValue]];
                                         [weakSelf setupFetchRequest];
                                         [weakSelf populateContent];
                                         weakSelf.loading = NO;
                                     }
                                 } failure:^(NSError *error) {
                                     if (weakSelf) {
                                         [weakSelf.refreshControl endRefreshing];
                                         weakSelf.loading = NO;
                                     }
                                 }];
}

- (void)loadMore {
    if (_loadingMore || !_item || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more item comments");
    MRSLComment *lastComment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                          withValue:[_commentIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getComments:_item
                               withMaxID:@([lastComment commentIDValue] - 1)
                               orSinceID:nil
                                andCount:@(10)
                                 success:^(NSArray *responseArray) {
                                     if (weakSelf) {
                                         if ([responseArray count] == 0) {
                                             weakSelf.loadedAll = YES;
                                         } else {
                                             [weakSelf.commentIDs addObjectsFromArray:responseArray];
                                             [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                       forKey:[NSString stringWithFormat:@"%i_commentIDs", _item.itemIDValue]];
                                             [weakSelf setupFetchRequest];
                                             [weakSelf populateContent];
                                         }
                                         weakSelf.loadingMore = NO;
                                     }
                                 } failure:^(NSError *error) {
                                     if (weakSelf) {
                                         weakSelf.loadingMore = NO;
                                     }
                                 }];
}

#pragma mark - Action Methods

- (IBAction)addComment {
    if (_item) {
        if (_commentInputTextView.text.length > 0) {
            [_commentInputTextView resignFirstResponder];
            [[MRSLEventManager sharedManager] track:@"Tapped Add Comment"
                                         properties:@{@"view": @"main_feed",
                                                      @"morsel_id": NSNullIfNil(_item.morsel.morselID),
                                                      @"item_id": NSNullIfNil(_item.itemID),
                                                      @"comment_count": NSNullIfNil(_item.comment_count)}];
            __weak __typeof (self) weakSelf = self;
            [_appDelegate.apiService addCommentWithDescription:_commentInputTextView.text
                                                      toMorsel:_item
                                                       success:^(id responseObject) {
                                                           if (responseObject && weakSelf) {
                                                               [weakSelf.commentIDs addObject:[(MRSLComment *)responseObject commentID]];
                                                               [weakSelf setupFetchRequest];
                                                               [weakSelf populateContent];
                                                               [weakSelf setLoading:NO];
                                                               if (weakSelf.commentsTableView.contentSize.height > [weakSelf.commentsTableView getHeight]) {
                                                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                       CGPoint bottomOffset = CGPointMake(0, weakSelf.commentsTableView.contentSize.height - weakSelf.commentsTableView.bounds.size.height);
                                                                       [weakSelf.commentsTableView setContentOffset:bottomOffset
                                                                                                           animated:YES];
                                                                   });
                                                               }
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
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat baselineY = self.view.frame.size.height - keyboardSize.height;
    if (![UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) baselineY -= [UIApplication sharedApplication].statusBarFrame.size.height;
    [UIView animateWithDuration:.35f
                     animations:^{
                         [_commentInputView setY:baselineY - [_commentInputView getHeight]];
                         [_commentsTableView setHeight:[_commentInputView getY] - [_commentsTableView getY]];
                         if (_commentsTableView.contentSize.height > [_commentsTableView getHeight]) {
                             CGPoint bottomOffset = CGPointMake(0, _commentsTableView.contentSize.height - _commentsTableView.bounds.size.height);
                             [_commentsTableView setContentOffset:bottomOffset
                                                         animated:NO];
                         }
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_commentInputView setY:self.view.frame.size.height - [_commentInputView getHeight]];
                         [_commentsTableView setHeight:[_commentInputView getY] - [_commentsTableView getY]];
                     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = ([_comments count] + ((_previousCommentsAvailable) ? 1 : 0));
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_previousCommentsAvailable && indexPath.row == 0) return 44;
    MRSLComment *comment = [_comments objectAtIndex:(indexPath.row - ((_previousCommentsAvailable) ? 1 : 0))];
    CGSize bodySize = [comment.commentDescription sizeWithFont:[UIFont robotoLightFontOfSize:12.f]
                                             constrainedToSize:CGSizeMake(MRSLDefaultCommentLabelWidth, CGFLOAT_MAX)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat defaultCellSize = 70.f;

    if (bodySize.height > MRSLDefaultCommentLabelHeight) {
        defaultCellSize = defaultCellSize + (bodySize.height - MRSLDefaultCommentLabelHeight);
    }
    return defaultCellSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_previousCommentsAvailable && indexPath.row == 0) {
        UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:(_loadingMore) ? MRSLStoryboardRUIDPreviousLoadingKey :
                                          MRSLStoryboardRUIDPreviousCommentCellKey];
        return tableViewCell;
    }
    MRSLComment *comment = [_comments objectAtIndex:(indexPath.row - ((_previousCommentsAvailable) ? 1 : 0))];
    MRSLCommentTableViewCell *commentCell = [self.commentsTableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDCommentCellKey];
    commentCell.comment = comment;
    commentCell.pipeView.hidden = (indexPath.row == [_comments count] - 1);
    return commentCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_previousCommentsAvailable && indexPath.row == 0) {
        if (_loadingMore) return;
        [self loadMore];
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
    } else {
        MRSLComment *comment = [_comments objectAtIndex:(indexPath.row - ((_previousCommentsAvailable) ? 1 : 0))];
        MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
        profileVC.user = comment.creator;
        [self.navigationController pushViewController:profileVC
                                             animated:YES];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu comments.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
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

#pragma mark - Destroy Methods

- (void)reset {
    [super reset];
    self.commentsTableView.dataSource = nil;
    self.commentsTableView.delegate = nil;
    [self.commentsTableView removeFromSuperview];
    self.commentsTableView = nil;
    self.commentInputTextView.delegate = nil;
    self.commentInputTextView.placeholder = nil;
    self.commentInputTextView.placeholderColor = nil;
}

@end
