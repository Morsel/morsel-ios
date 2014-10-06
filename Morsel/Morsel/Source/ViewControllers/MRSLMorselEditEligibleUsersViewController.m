//
//  MRSLMorselEditEligibleUsersViewController.m
//  Morsel
//
//  Created by Javier Otero on 10/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditEligibleUsersViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLTableView.h"
#import "MRSLEligibleUserTableViewCell.h"
#import "MRSLProfileViewController.h"

#import "MRSLUser.h"

@interface MRSLMorselEditEligibleUsersViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *eligibleUsers;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *userIDs;

@end

@implementation MRSLMorselEditEligibleUsersViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"eligible_users";

    self.eligibleUsers = [NSMutableArray array];

    self.userIDs = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
    self.tableView.alwaysBounceVertical = YES;
    [self.tableView setEmptyStateTitle:@"No one to tag."];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
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
    self.eligibleUsers = [_fetchedResultsController fetchedObjects];
    [self.tableView reloadData];
}

- (void)refreshContent {
    if (_loading) return;
    self.loadedAll = NO;
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getEligibleTaggedUsersForMorsel:_morsel
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
    [_appDelegate.apiService getEligibleTaggedUsersForMorsel:_morsel
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
    return [_eligibleUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_eligibleUsers objectAtIndex:indexPath.row];

    MRSLEligibleUserTableViewCell *eligibleCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserEligibleCellKey];
    [eligibleCell setUser:user
                andMorsel:_morsel];
    eligibleCell.pipeView.hidden = (indexPath.row == [_eligibleUsers count] - 1);

    return eligibleCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_eligibleUsers objectAtIndex:indexPath.row];
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Tag",
                                              @"tagged_user_id": user.userID}];

    [user setTaggedValue:!user.taggedValue];

    [_appDelegate.apiService tagUser:user
                            toMorsel:_morsel
                           shouldTag:user.taggedValue
                              didTag:^(BOOL didTag) {
                                  if (user.taggedValue) [MRSLEventManager sharedManager].users_tagged++;
                              } failure:^(NSError *error) {
                                  [user setTaggedValue:!user.taggedValue];
                              }];
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
