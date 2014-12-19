//
//  MRSLFindUsersViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFindUsersViewController.h"

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
#import "MRSLTableViewDataSource.h"

#import "MRSLUser.h"

@interface MRSLBaseRemoteDataSourceViewController (Private)

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface MRSLFindUsersViewController ()
<UISearchBarDelegate,
MRSLSegmentedButtonViewDelegate,
MRSLTableViewDataSourceDelegate>

@property (nonatomic) NSInteger friendSection;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSString *socialProvider;
@property (strong, nonatomic) NSString *socialFriendUIDs;

@property (strong, nonatomic) NSTimer *searchTimer;

@end

@implementation MRSLFindUsersViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"find_users";
    [self.tableView setEmptyStateTitle:@"No users found."];

    [self setupRemoteRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self suspendTimer];
}

#pragma mark - Private Methods

- (BOOL)shouldShowSuggestedPeople {
    return _friendSection == 0 && [_searchBar.text length] < 3;
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%li_findusers_%@_userIDs", (long)_friendSection, ([self shouldShowSuggestedPeople] ? @"suggested" : @"all")];
}

- (MRSLDataSource *)dataSource {
    MRSLTableViewDataSource *superDataSource = (MRSLTableViewDataSource *)[super dataSource];
    if (superDataSource) return superDataSource;
    MRSLTableViewDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                                           configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                                               if (![item isKindOfClass:[MRSLUser class]]) {
                                                                                   return [[MRSLUserFollowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
                                                                               } else {
                                                                                   MRSLUser *user = item;
                                                                                   MRSLUserFollowTableViewCell *userFollowCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserFollowCellKey];
                                                                                   userFollowCell.user = user;
                                                                                   userFollowCell.pipeView.hidden = (indexPath.row == count - 1);
                                                                                   return userFollowCell;
                                                                               }
                                                                           }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    NSPredicate *predicate = nil;
    if (_friendSection > 0 && [_searchBar.text length] > 0) {
        // Filter names
        predicate = [NSPredicate predicateWithFormat:@"userID IN %@ && (first_name CONTAINS[cd] %@ || last_name CONTAINS[cd] %@)", self.objectIDs, _searchBar.text, _searchBar.text];
    } else {
        // Search API
        predicate = [NSPredicate predicateWithFormat:@"userID IN %@", self.objectIDs];
    }

    return [MRSLUser MR_fetchAllSortedBy:@"userID"
                               ascending:NO
                           withPredicate:predicate
                                 groupBy:nil
                                delegate:self
                               inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)setupRemoteRequest {
    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.friendSection > 0) {
            [_appDelegate.apiService getSocialProviderConnections:strongSelf.socialProvider
                                                        usingUIDs:strongSelf.socialFriendUIDs
                                                             page:page
                                                            count:nil
                                                          success:^(NSArray *responseArray) {
                                                              remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                          } failure:^(NSError *error) {
                                                              remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                          }];
        } else {
            [_appDelegate.apiService searchUsersWithQuery:strongSelf.searchBar.text
                                                     page:page
                                                    count:nil
                                                  success:^(NSArray *responseArray) {
                                                      remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                  } failure:^(NSError *error) {
                                                      remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                  }];
        }
    };
}

- (void)loadFacebookFriends {
    [[MRSLSocialServiceFacebook sharedService] getFacebookFriendUIDs:^(NSString *uids, NSError *error) {
        if (!error) {
            DDLogDebug(@"Facebook friend UIDs: %@", uids);
            [self loadSocialUIDs:uids];
        } else {
            DDLogError(@"Failed to retrieve Facebook friend UIDs: %@", error);
        }
    }];
}

- (void)loadTwitterFriends {
    [[MRSLSocialServiceTwitter sharedService] getTwitterFollowingUIDs:^(NSString *uids, NSError *error) {
        if (!error) {
            DDLogDebug(@"Twitter friend UIDs: %@", uids);
            [self loadSocialUIDs:uids];
        } else {
            DDLogError(@"Failed to retrieve Twitter friend UIDs: %@", error);
        }
    }];
}

- (void)loadInstagramFriends {
    [[MRSLSocialServiceInstagram sharedService] getInstagramFollowingUIDs:^(NSString *uids, NSError *error) {
        if (!error) {
            DDLogDebug(@"Instagram friend UIDs: %@", uids);
            [self loadSocialUIDs:uids];
        } else {
            DDLogError(@"Failed to retrieve Instagram friend UIDs: %@", error);
        }
    }];
}

- (void)loadSocialUIDs:(NSString *)uids {
    self.socialFriendUIDs = uids;
    if ([_socialFriendUIDs length] > 0) {
        [self setupRemoteRequest];
        [self refreshRemoteContent];
    } else {
        [self.dataSource updateObjects:@[]];
        [self refreshLocalContent];
    }
}

#pragma mark - MRSLSegmentedButtonViewDelegate

- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index {
    self.friendSection = index;

    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];

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

    [self triggerSearch];
}

#pragma mark - MRSLTableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_friendSection == 0) {
        return [MRSLSectionView sectionViewWithTitle:([self shouldShowSuggestedPeople] ? @"Suggested users" : @"Search results")];
    } else {
        return [MRSLSectionView sectionViewWithTitle:@"Users found"];
    }
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item {
    MRSLUser *user = item;
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
    profileVC.user = user;
    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView {
    [super tableViewDataSourceScrollViewDidScroll:scrollView];
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
                                                 selector:@selector(triggerSearch)
                                                 userInfo:nil
                                                  repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_searchTimer
                                     forMode:NSRunLoopCommonModes];
    }
}

- (void)triggerSearch {
    [self setupRemoteRequest];
    [self refreshRemoteContent];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([self shouldShowSuggestedPeople]) {
        [self refreshLocalContent];
    } else if (_friendSection > 0) {
        [self suspendTimer];
        [self refreshLocalContent];
    }
    if (_friendSection == 0) [self resumeTimer];
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

@end
