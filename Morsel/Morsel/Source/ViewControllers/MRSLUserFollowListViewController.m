//
//  MRSLUserFollowListViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserFollowListViewController.h"

#import "MRSLAPIService+Follow.h"

#import "MRSLUserFollowTableViewCell.h"
#import "MRSLProfileViewController.h"

#import "MRSLUser.h"

#import "MRSLTableView.h"

@interface MRSLUserFollowListViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet MRSLTableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *userIDs;

@end

@implementation MRSLUserFollowListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_user) self.user = [MRSLUser currentUser];

    self.userIDs = [NSMutableArray array];

    self.title = _shouldDisplayFollowers ? @"Followers" : @"Following";

    self.users = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
    self.tableView.alwaysBounceVertical = YES;

    [self.tableView setEmptyStateTitle:_shouldDisplayFollowers ? @"No followers yet." : @"Not following anyone."];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                      animated:YES];
        self.selectedIndexPath = nil;
    }

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

    [self.tableView toggleLoading:loading];
}

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLUser MR_fetchAllSortedBy:@"dateFollowed"
                                                       ascending:NO
                                                   withPredicate:[NSPredicate predicateWithFormat:@"userID IN %@", _userIDs]
                                                         groupBy:nil
                                                        delegate:self
                                                       inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.users = [_fetchedResultsController fetchedObjects];
    [self.tableView reloadData];
}

- (void)refreshContent {
    if (_loading) return;
    self.loadedAll = NO;
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    if (_shouldDisplayFollowers) {
        [_appDelegate.apiService getUserFollowers:_user
                                        withMaxID:nil
                                        orSinceID:nil
                                         andCount:nil
                                          success:^(NSArray *responseArray) {
                                              [weakSelf.refreshControl endRefreshing];
                                              weakSelf.userIDs = [responseArray mutableCopy];
                                              [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                        forKey:[NSString stringWithFormat:@"%@_%@_userIDs", _user.username, _shouldDisplayFollowers ? @"followers" : @"following"]];
                                              [weakSelf setupFetchRequest];
                                              [weakSelf populateContent];
                                              weakSelf.loading = NO;
                                          } failure:^(NSError *error) {
                                              [weakSelf.refreshControl endRefreshing];
                                              weakSelf.loading = NO;
                                          }];
    } else {
        [_appDelegate.apiService getUserFollowables:_user
                                          withMaxID:nil
                                          orSinceID:nil
                                           andCount:nil
                                            success:^(NSArray *responseArray) {
                                                [weakSelf.refreshControl endRefreshing];
                                                weakSelf.userIDs = [responseArray mutableCopy];
                                                [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                          forKey:[NSString stringWithFormat:@"%@_%@_userIDs", _user.username, _shouldDisplayFollowers ? @"followers" : @"following"]];
                                                [weakSelf setupFetchRequest];
                                                [weakSelf populateContent];
                                                weakSelf.loading = NO;
                                            } failure:^(NSError *error) {
                                                [weakSelf.refreshControl endRefreshing];
                                                weakSelf.loading = NO;
                                            }];
    }
}

- (void)loadMore {
    if (_loadingMore || !_user || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more");
    MRSLUser *lastUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                              withValue:[_userIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    if (_shouldDisplayFollowers) {
        [_appDelegate.apiService getUserFollowers:_user
                                        withMaxID:@([lastUser userIDValue] - 1)
                                        orSinceID:nil
                                         andCount:@(12)
                                          success:^(NSArray *responseArray) {
                                              if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                              DDLogDebug(@"%lu objects added", (unsigned long)[responseArray count]);
                                              if (weakSelf) {
                                                  if ([responseArray count] > 0) {
                                                      [weakSelf.userIDs addObjectsFromArray:responseArray];
                                                      [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userIDs
                                                                                                forKey:[NSString stringWithFormat:@"%@_%@_userIDs", _user.username, _shouldDisplayFollowers ? @"followers" : @"following"]];
                                                      [weakSelf setupFetchRequest];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [weakSelf populateContent];
                                                      });
                                                  }
                                                  weakSelf.loadingMore = NO;
                                              }
                                          } failure:^(NSError *error) {
                                              if (weakSelf) weakSelf.loadingMore = NO;
                                          }];
    } else {
        [_appDelegate.apiService getUserFollowables:_user
                                          withMaxID:@([lastUser userIDValue] - 1)
                                          orSinceID:nil
                                           andCount:@(12)
                                            success:^(NSArray *responseArray) {
                                                if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                                DDLogDebug(@"%lu objects added", (unsigned long)[responseArray count]);
                                                if (weakSelf) {
                                                    if ([responseArray count] > 0) {
                                                        [weakSelf.userIDs addObjectsFromArray:responseArray];
                                                        [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userIDs
                                                                                                  forKey:[NSString stringWithFormat:@"%@_%@_userIDs", _user.username, _shouldDisplayFollowers ? @"followers" : @"following"]];
                                                        [weakSelf setupFetchRequest];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [weakSelf populateContent];
                                                        });
                                                    }
                                                    weakSelf.loadingMore = NO;
                                                }
                                            } failure:^(NSError *error) {
                                                if (weakSelf) weakSelf.loadingMore = NO;
                                            }];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_users count];
}

- (MRSLUserFollowTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_users objectAtIndex:indexPath.row];
    MRSLUserFollowTableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:@"ruid_UserFollowCell"];
    userCell.user = user;
    userCell.pipeView.hidden = (indexPath.row == [_users count] - 1);
    return userCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_users objectAtIndex:indexPath.row];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileViewController"];
    profileVC.user = user;
    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"NSFetchedResultsController detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.f) {
        [self loadMore];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
