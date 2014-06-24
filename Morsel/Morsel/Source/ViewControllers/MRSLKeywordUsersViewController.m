//
//  MRSLKeywordFollowersViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLKeywordUsersViewController.h"

#import "MRSLAPIService+Tag.h"

#import "MRSLUserFollowTableViewCell.h"
#import "MRSLProfileViewController.h"

#import "MRSLKeyword.h"
#import "MRSLUser.h"

@interface MRSLKeywordUsersViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *userIDs;

@end

@implementation MRSLKeywordUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _keyword.name;

    self.userIDs = [NSMutableArray array];

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
    __weak __typeof(self)weakSelf = self;
    if ([_keyword isCuisineType]) {
        [_appDelegate.apiService getCuisineUsers:_keyword
                                         success:^(NSArray *responseArray) {
                                             [weakSelf.refreshControl endRefreshing];
                                             weakSelf.userIDs = [responseArray mutableCopy];
                                             [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                       forKey:[NSString stringWithFormat:@"%i_userIDs", _keyword.keywordIDValue]];
                                             [weakSelf setupFetchRequest];
                                             [weakSelf populateContent];
                                         } failure:^(NSError *error) {
                                             [weakSelf.refreshControl endRefreshing];
                                         }];
    } else {
        [_appDelegate.apiService getSpecialtyUsers:_keyword
                                           success:^(NSArray *responseArray) {
                                               [weakSelf.refreshControl endRefreshing];
                                               weakSelf.userIDs = [responseArray mutableCopy];
                                               [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                         forKey:[NSString stringWithFormat:@"%i_userIDs", _keyword.keywordIDValue]];
                                               [weakSelf setupFetchRequest];
                                               [weakSelf populateContent];
                                           } failure:^(NSError *error) {
                                               [weakSelf.refreshControl endRefreshing];
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
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
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
