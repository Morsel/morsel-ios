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
#import "MRSLTableViewDataSource.h"
#import "MRSLEligibleUserTableViewCell.h"
#import "MRSLProfileViewController.h"

#import "MRSLUser.h"

@interface MRSLBaseRemoteDataSourceViewController (Private)

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface MRSLMorselEditEligibleUsersViewController ()
<MRSLTableViewDataSourceDelegate,
UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSTimer *searchTimer;

@end

@implementation MRSLMorselEditEligibleUsersViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"eligible_users";

    [self setupRemoteRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(morselEditEligibleUsersViewController:viewWillDisappearWithTaggedUserCount:)]) {
        [self.delegate morselEditEligibleUsersViewController:self
                    viewWillDisappearWithTaggedUserCount:5];
        //  TODO: Get tagged user count ^
    }
}

#pragma mark - Private Methods

- (NSString *)objectIDsKey {
    return @"eligible_tagged_userIDs";
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLUser MR_fetchAllSortedBy:@"userID"
                                ascending:NO
                            withPredicate:[NSPredicate predicateWithFormat:@"userID IN %@", self.objectIDs]
                                  groupBy:nil
                                 delegate:self
                                inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
        MRSLUser *user = item;

        MRSLEligibleUserTableViewCell *eligibleCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserEligibleCellKey];
        [eligibleCell setUser:user
                    andMorsel:_morsel];
        eligibleCell.pipeView.hidden = (indexPath.row == count - 1);

        return eligibleCell;
    }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

- (void)setupRemoteRequest {
    [self.tableView setEmptyStateTitle:(_searchBar.text.length > 0) ? @"No results" : @"No one to tag"];
    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [_appDelegate.apiService getEligibleTaggedUsersForMorsel:strongSelf.morsel
                                                      usingQuery:strongSelf.searchBar.text
                                                            page:page
                                                           count:nil
                                                         success:^(NSArray *responseArray) {
                                                             remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                         } failure:^(NSError *error) {
                                                             remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                         }];
    };
}

#pragma mark - MRSLTableViewDataSourceDelegate

- (void)tableViewDataSource:(UITableView *)tableView didSelectItem:(id)item {
    MRSLUser *user = item;
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

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView {
    [super tableViewDataSourceScrollViewDidScroll:scrollView];
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO
                                    animated:YES];
    }
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
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
        self.searchTimer = [NSTimer timerWithTimeInterval:MRSLSearchDelayDefault
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
    [self resumeTimer];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar setShowsCancelButton:NO
                               animated:YES];
        [searchBar resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO
                           animated:YES];
    [self.view endEditing:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES
                           animated:YES];
}

@end
