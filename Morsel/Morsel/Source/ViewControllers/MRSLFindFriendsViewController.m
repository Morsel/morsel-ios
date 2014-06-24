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

#import "MRSLUser.h"

@interface MRSLFindFriendsViewController ()
<NSFetchedResultsControllerDelegate,
UISearchBarDelegate,
UITableViewDataSource,
MRSLSegmentedButtonViewDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (nonatomic) NSInteger friendSection;

@property (weak, nonatomic) IBOutlet UIView *nullStateView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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

    self.userIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%li_findfriend_userIDs", (long)_friendSection]] ?: [NSMutableArray array];

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

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self suspendTimer];
}

#pragma mark - Private Methods

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

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

    self.nullStateView.hidden = ([_users count] > 0);
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.refreshing = YES;
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
                                                          [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                                    forKey:[NSString stringWithFormat:@"%li_findfriend_userIDs", (long)_friendSection]];
                                                          [weakSelf setupFetchRequest];
                                                          [weakSelf populateContent];
                                                          weakSelf.refreshing = NO;
                                                      } failure:^(NSError *error) {
                                                          [weakSelf.refreshControl endRefreshing];
                                                          weakSelf.refreshing = NO;
                                                      }];
    } else {
        [_appDelegate.apiService searchWithQuery:_searchBar.text
                                           maxID:nil
                                       orSinceID:nil
                                        andCount:nil
                                         success:^(NSArray *responseArray) {
                                             [weakSelf.refreshControl endRefreshing];
                                             weakSelf.userIDs = [responseArray mutableCopy];
                                             [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                       forKey:[NSString stringWithFormat:@"%li_findfriend_userIDs", (long)_friendSection]];
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
    if (_loadingMore || _loadedAll || _refreshing) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more users");
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
                                                                  [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userIDs
                                                                                                            forKey:[NSString stringWithFormat:@"%li_findfriend_userIDs", (long)_friendSection]];
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
        [_appDelegate.apiService searchWithQuery:_searchBar.text
                                           maxID:@([lastUser userIDValue] - 1)
                                       orSinceID:nil
                                        andCount:@(12)
                                         success:^(NSArray *responseArray) {
                                             if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                             DDLogDebug(@"%lu users added", (unsigned long)[responseArray count]);
                                             if (weakSelf) {
                                                 if ([responseArray count] > 0) {
                                                     [weakSelf.userIDs addObjectsFromArray:responseArray];
                                                     [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userIDs
                                                                                               forKey:[NSString stringWithFormat:@"%li_findfriend_userIDs", (long)_friendSection]];
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

#pragma mark - MRSLSegmentedButtonViewDelegate

- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index {
    self.friendSection = index;

    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];

    self.userIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%li_findfriend_userIDs", (long)_friendSection]] ?: [NSMutableArray array];
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
        self.searchBar.placeholder = @"Find people on Morsel";
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
    MRSLUser *user = [_users objectAtIndex:indexPath.row];
    MRSLUserFollowTableViewCell *userFollowCell = [tableView dequeueReusableCellWithIdentifier:@"ruid_UserFollowCell"];
    userFollowCell.user = user;
    userFollowCell.pipeView.hidden = (indexPath.row == [_users count] - 1);
    return userFollowCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_friendSection == 0) {
        if ([_searchBar.text length] < 3) {
            return @"Suggested People";
        } else {
            return @"Search Results";
        }
    } else {
        return nil;
    }
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
        [searchBar resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

#pragma mark - Dealloc

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
