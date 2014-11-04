//
//  MRSLMorselTaggedUsersViewController.m
//  Morsel
//
//  Created by Javier Otero on 10/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselTaggedUsersViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLTableView.h"
#import "MRSLUserFollowTableViewCell.h"
#import "MRSLProfileViewController.h"

#import "MRSLUser.h"

@interface MRSLMorselTaggedUsersViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *taggedUsers;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *userIDs;

@end

@implementation MRSLMorselTaggedUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"tagged_users";

    self.taggedUsers = [NSMutableArray array];

    self.userIDs = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
    self.tableView.alwaysBounceVertical = YES;

    [self.tableView setEmptyStateTitle:@"No tagged users"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_fetchedResultsController) return;

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

#pragma mark - Private Methods

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.tableView toggleLoading:loading];
}

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLUser MR_fetchAllSortedBy:@"userID"
                                                        ascending:NO
                                                    withPredicate:[NSPredicate predicateWithFormat:@"userID IN %@", _userIDs]
                                                          groupBy:nil
                                                         delegate:self
                                                        inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.taggedUsers = [_fetchedResultsController fetchedObjects];
    [self.tableView reloadData];
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getTaggedUsersForMorsel:_morsel
                                           withMaxID:nil
                                           orSinceID:nil
                                            andCount:nil
                                             success:^(NSArray *responseArray) {
                                                 if (weakSelf) {
                                                     [weakSelf.refreshControl endRefreshing];
                                                     weakSelf.userIDs = [responseArray mutableCopy];
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
    if (_loadingMore || !_morsel || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more");
    MRSLUser *lastUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                 withValue:[_userIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getTaggedUsersForMorsel:_morsel
                                           withMaxID:@([lastUser userIDValue] - 1)
                                           orSinceID:nil
                                            andCount:@(10)
                                             success:^(NSArray *responseArray) {
                                                 if (weakSelf) {
                                                     if ([responseArray count] == 0) {
                                                         weakSelf.loadedAll = YES;
                                                     } else {
                                                         [weakSelf.userIDs addObjectsFromArray:responseArray];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_taggedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_taggedUsers objectAtIndex:indexPath.row];

    MRSLUserFollowTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserFollowCellKey];
    userCell.user = user;
    userCell.pipeView.hidden = (indexPath.row == [_taggedUsers count] - 1);

    return userCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_taggedUsers objectAtIndex:indexPath.row];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
    profileVC.user = user;
    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.f) {
        [self loadMore];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu comments.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
