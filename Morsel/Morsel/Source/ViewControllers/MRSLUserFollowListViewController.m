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

#import "MRSLUser.h"

@interface MRSLUserFollowListViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *userIDs;

@end

@implementation MRSLUserFollowListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userIDs = [NSMutableArray array];

    self.title = _shouldDisplayFollowing ? @"Following" : @"Followers";

    self.users = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
    self.tableView.alwaysBounceVertical = YES;
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

#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLUser MR_fetchAllSortedBy:@"last_name"
                                                       ascending:YES
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
    self.loadedAll = NO;
    self.refreshing = YES;
    __weak __typeof(self)weakSelf = self;
    if (_shouldDisplayFollowing) {
        [_appDelegate.apiService getUserFollowables:_user
                                          withMaxID:nil
                                          orSinceID:nil
                                           andCount:nil
                                            success:^(NSArray *responseArray) {
                                                [weakSelf.refreshControl endRefreshing];
                                                weakSelf.userIDs = [responseArray mutableCopy];
                                                [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                          forKey:[NSString stringWithFormat:@"%@_%@_tagIDs", _user.username, _shouldDisplayFollowing ? @"following" : @"followers"]];
                                                [weakSelf setupFetchRequest];
                                                [weakSelf populateContent];
                                                weakSelf.refreshing = NO;
                                            } failure:^(NSError *error) {
                                                [weakSelf.refreshControl endRefreshing];
                                                weakSelf.refreshing = NO;
                                            }];
    } else {
        [_appDelegate.apiService getUserFollowers:_user
                                        withMaxID:nil
                                        orSinceID:nil
                                         andCount:nil
                                          success:^(NSArray *responseArray) {
                                              [weakSelf.refreshControl endRefreshing];
                                              weakSelf.userIDs = [responseArray mutableCopy];
                                              [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                        forKey:[NSString stringWithFormat:@"%@_%@_tagIDs", _user.username, _shouldDisplayFollowing ? @"following" : @"followers"]];
                                              [weakSelf setupFetchRequest];
                                              [weakSelf populateContent];
                                              weakSelf.refreshing = NO;
                                          } failure:^(NSError *error) {
                                              [weakSelf.refreshControl endRefreshing];
                                              weakSelf.refreshing = NO;
                                          }];
    }
}

- (void)loadMore {
    if (_loadingMore || !_user || _loadedAll || _refreshing) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more user tags");
    MRSLUser *lastUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                              withValue:[_userIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    if (_shouldDisplayFollowing) {
        [_appDelegate.apiService getUserFollowables:_user
                                          withMaxID:nil
                                          orSinceID:nil
                                           andCount:nil
                                            success:^(NSArray *responseArray) {
                                                [weakSelf.refreshControl endRefreshing];
                                                weakSelf.userIDs = [responseArray mutableCopy];
                                                [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                          forKey:[NSString stringWithFormat:@"%@_%@_tagIDs", _user.username, _shouldDisplayFollowing ? @"following" : @"followers"]];
                                                [weakSelf setupFetchRequest];
                                                [weakSelf populateContent];
                                                weakSelf.refreshing = NO;
                                            } failure:^(NSError *error) {
                                                [weakSelf.refreshControl endRefreshing];
                                                weakSelf.refreshing = NO;
                                            }];
    } else {
        [_appDelegate.apiService getUserFollowers:_user
                                        withMaxID:@([lastUser userIDValue] - 1)
                                        orSinceID:nil
                                         andCount:@(12)
                                          success:^(NSArray *responseArray) {
                                              if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                              DDLogDebug(@"%lu user tags added", (unsigned long)[responseArray count]);
                                              if (weakSelf) {
                                                  if ([responseArray count] > 0) {
                                                      [weakSelf.userIDs addObjectsFromArray:responseArray];
                                                      [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userIDs
                                                                                                forKey:[NSString stringWithFormat:@"%@_%@_tagIDs", _user.username, _shouldDisplayFollowing ? @"following" : @"followers"]];
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

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
