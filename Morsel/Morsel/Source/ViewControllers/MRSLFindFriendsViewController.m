//
//  MRSLFindFriendsViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFindFriendsViewController.h"

#import "MRSLAPIService+Authentication.h"
#import "MRSLAPIService+Search.h"

#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceInstagram.h"
#import "MRSLSocialServiceTwitter.h"

#import "MRSLSegmentedButtonView.h"
#import "MRSLUserFollowTableViewCell.h"
#import "MRSLProfileViewController.h"
#import "MRSLSectionView.h"
#import "MRSLTableView.h"

#import "MRSLUser.h"

@interface MRSLFindFriendsViewController ()
<NSFetchedResultsControllerDelegate,
UISearchBarDelegate,
UITableViewDataSource,
MRSLSegmentedButtonViewDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (nonatomic) NSInteger friendSection;

@property (weak, nonatomic) IBOutlet MRSLTableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *userIDs;
@property (strong, nonatomic) NSString *socialProvider;
@property (strong, nonatomic) NSString *socialFriendUIDs;

@property (strong, nonatomic) NSTimer *searchTimer;

@end

@implementation MRSLFindFriendsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[self objectIDsKey]] ?: [NSMutableArray array];

    self.users = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
    self.tableView.alwaysBounceVertical = YES;

    [self.tableView setEmptyStateTitle:@"No people found."];
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
    [self suspendTimer];
}

#pragma mark - Private Methods

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.tableView toggleLoading:loading];
}

- (void)setupFetchRequest {
    NSPredicate *predicate = nil;
    if (_friendSection > 0 && [_searchBar.text length] > 0) {
        // Filter names
        predicate = [NSPredicate predicateWithFormat:@"userID IN %@ && (first_name CONTAINS[cd] %@ || last_name CONTAINS[cd] %@)", _userIDs, _searchBar.text, _searchBar.text];
    } else {
        // Search API
        predicate = [NSPredicate predicateWithFormat:@"userID IN %@", _userIDs];
    }

    self.fetchedResultsController = [MRSLUser MR_fetchAllSortedBy:@"userID"
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self
                                                        inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.users = [_fetchedResultsController fetchedObjects];

    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            [weakSelf.tableView reloadData];
            weakSelf.loading = NO;
        }
    });
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    if (_friendSection > 0) {
        [_appDelegate.apiService getSocialProviderConnections:_socialProvider
                                                    usingUIDs:_socialFriendUIDs
                                                        maxID:nil
                                                    orSinceID:nil
                                                     andCount:nil
                                                      success:^(NSArray *responseArray) {
                                                          [weakSelf.refreshControl endRefreshing];
                                                          weakSelf.userIDs = [responseArray mutableCopy];
                                                          [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.userIDs copy]
                                                                                                    forKey:[self objectIDsKey]];
                                                          [weakSelf setupFetchRequest];
                                                          [weakSelf populateContent];
                                                          weakSelf.loading = NO;
                                                      } failure:^(NSError *error) {
                                                          [weakSelf.refreshControl endRefreshing];
                                                          weakSelf.loading = NO;
                                                      }];
    } else {
        [_appDelegate.apiService searchUsersWithQuery:_searchBar.text
                                                maxID:nil
                                            orSinceID:nil
                                             andCount:nil
                                              success:^(NSArray *responseArray) {
                                                  [weakSelf.refreshControl endRefreshing];
                                                  weakSelf.userIDs = [responseArray mutableCopy];
                                                  [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.userIDs copy]
                                                                                            forKey:[self objectIDsKey]];
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
    if (_loadingMore || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more");
    MRSLUser *lastUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                 withValue:[_userIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    if (_friendSection > 0) {
        [_appDelegate.apiService getSocialProviderConnections:_socialProvider
                                                    usingUIDs:_socialFriendUIDs
                                                        maxID:@([lastUser userIDValue] - 1)
                                                    orSinceID:nil
                                                     andCount:@(12)
                                                      success:^(NSArray *responseArray) {
                                                          if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                                          DDLogDebug(@"%lu users added", (unsigned long)[responseArray count]);
                                                          if (weakSelf) {
                                                              if ([responseArray count] > 0) {
                                                                  [weakSelf.userIDs addObjectsFromArray:responseArray];
                                                                  [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.userIDs copy]
                                                                                                            forKey:[self objectIDsKey]];
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
        [_appDelegate.apiService searchUsersWithQuery:_searchBar.text
                                                maxID:@([lastUser userIDValue] - 1)
                                            orSinceID:nil
                                             andCount:@(12)
                                              success:^(NSArray *responseArray) {
                                                  if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                                  DDLogDebug(@"%lu users added", (unsigned long)[responseArray count]);
                                                  if (weakSelf) {
                                                      if ([responseArray count] > 0) {
                                                          [weakSelf.userIDs addObjectsFromArray:responseArray];
                                                          [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.userIDs copy]
                                                                                                    forKey:[self objectIDsKey]];
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

#pragma mark - Private Methods

- (void)loadFacebookFriends {
    [[MRSLSocialServiceFacebook sharedService] getFacebookFriendUIDs:^(NSString *uids, NSError *error) {
        if (!error) {
            DDLogDebug(@"Facebook friend UIDs: %@", uids);
            self.socialFriendUIDs = uids;
            if ([_socialFriendUIDs length] > 0) [self refreshContent];
        } else {
            DDLogError(@"Failed to retrieve Facebook friend UIDs: %@", error);
        }
    }];
}

- (void)loadTwitterFriends {
    [[MRSLSocialServiceTwitter sharedService] getTwitterFollowingUIDs:^(NSString *uids, NSError *error) {
        if (!error) {
            DDLogDebug(@"Twitter friend UIDs: %@", uids);
            self.socialFriendUIDs = uids;
            if ([_socialFriendUIDs length] > 0) [self refreshContent];
        } else {
            DDLogError(@"Failed to retrieve Twitter friend UIDs: %@", error);
        }
    }];
}

- (void)loadInstagramFriends {
    [[MRSLSocialServiceInstagram sharedService] getInstagramFollowingUIDs:^(NSString *uids, NSError *error) {
        if (!error) {
            DDLogDebug(@"Instagram friend UIDs: %@", uids);
            self.socialFriendUIDs = uids;
            if ([_socialFriendUIDs length] > 0) [self refreshContent];
        } else {
            DDLogError(@"Failed to retrieve Instagram friend UIDs: %@", error);
        }
    }];
}

- (BOOL)shouldShowSuggestedPeople {
    return _friendSection == 0 && [_searchBar.text length] < 3;
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%li_findfriend_%@_userIDs", (long)_friendSection, ([self shouldShowSuggestedPeople] ? @"suggested" : @"all")];
}

#pragma mark - MRSLSegmentedButtonViewDelegate

- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index {
    self.friendSection = index;

    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];

    self.userIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[self objectIDsKey]] ?: [NSMutableArray array];
    [self setupFetchRequest];
    [self populateContent];

    if (_friendSection > 0) {
        self.searchBar.placeholder = @"Filter";
        if (_friendSection == 1) {
            self.socialProvider = @"facebook";
            if ([FBSession.activeSession isOpen]) {
                [self loadFacebookFriends];
            } else {
                [[MRSLSocialServiceFacebook sharedService] openFacebookSessionWithSessionStateHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                    if ([session isOpen]) {
                        [self loadFacebookFriends];
                    } else if (error) {
                        //Display empty tell friends state
                        [MRSLSocialServiceFacebook sharedService].sessionStateHandlerBlock = nil;
                    }
                }];
            }
        } else if (_friendSection == 2) {
            self.socialProvider = @"twitter";
            [[MRSLSocialServiceTwitter sharedService] checkForValidTwitterAuthenticationWithSuccess:^(BOOL success) {
                [self loadTwitterFriends];
            } failure:^(NSError *error) {
                [[MRSLSocialServiceTwitter sharedService] authenticateWithTwitterWithSuccess:^(BOOL success) {
                    [self loadTwitterFriends];
                } failure:^(NSError *error) {
                    //Display empty tell friends state
                }];
            }];
        } else if (_friendSection == 3) {
            self.socialProvider = @"instagram";
            [[MRSLSocialServiceInstagram sharedService] checkForValidInstagramAuthenticationWithSuccess:^(BOOL success) {
                [self loadInstagramFriends];
            } failure:^(NSError *error) {
                [[MRSLSocialServiceInstagram sharedService] authenticateWithInstagramWithSuccess:^(BOOL success) {
                    [self loadInstagramFriends];
                } failure:^(NSError *error) {
                    //Display empty tell friends state
                }];
            }];

        }
    } else {
        self.searchBar.placeholder = @"Find users on Morsel";
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_users count];
}

- (MRSLUserFollowTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_users count]) {
        return [[MRSLUserFollowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
    } else {
        MRSLUser *user = [_users objectAtIndex:indexPath.row];
        MRSLUserFollowTableViewCell *userFollowCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserFollowCellKey];
        userFollowCell.user = user;
        userFollowCell.pipeView.hidden = (indexPath.row == [_users count] - 1);
        return userFollowCell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_friendSection == 0) {
        return [MRSLSectionView sectionViewWithTitle:([self shouldShowSuggestedPeople] ? @"Suggested people" : @"Search results")];
    } else {
        return [MRSLSectionView sectionViewWithTitle:@"People found"];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > [_users count] - 1) return;
    MRSLUser *user = [_users objectAtIndex:indexPath.row];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
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
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)suspendTimer {
    if (_searchTimer) {
        [_searchTimer invalidate];
        self.searchTimer = nil;
    }
}

- (void)resumeTimer {
    [self suspendTimer];
    if (!_searchTimer) {
        self.searchTimer = [NSTimer timerWithTimeInterval:.1f
                                                   target:self
                                                 selector:@selector(refreshContent)
                                                 userInfo:nil
                                                  repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_searchTimer
                                     forMode:NSRunLoopCommonModes];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self setupFetchRequest];
    [self populateContent];
    if (_friendSection == 0) {
        [self resumeTimer];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar setShowsCancelButton:NO animated:YES];
        [searchBar resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
