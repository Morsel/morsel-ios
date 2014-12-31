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
#import "MRSLTableView.h"
#import "MRSLTableViewDataSource.h"

#import "MRSLUser.h"

@interface MRSLUserFollowListViewController ()
<MRSLTableViewDataSourceDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation MRSLUserFollowListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_user) self.user = [MRSLUser currentUser];

    self.title = _shouldDisplayFollowers ? @"Followers" : @"Following";

    [self.tableView setEmptyStateTitle:_shouldDisplayFollowers ? @"No followers yet." : @"Not following anyone."];

    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.shouldDisplayFollowers) {
            [_appDelegate.apiService getUserFollowers:strongSelf.user
                                                 page:page
                                                count:nil
                                              success:^(NSArray *responseArray) {
                                                  remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                              } failure:^(NSError *error) {
                                                  remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                              }];
        } else {
            [_appDelegate.apiService getUserFollowables:strongSelf.user
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                      animated:YES];
        self.selectedIndexPath = nil;
    }
}

#pragma mark - Private Methods

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%@_%@_userIDs", _user.username, _shouldDisplayFollowers ? @"followers" : @"following"];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLUser MR_fetchAllSortedBy:@"dateFollowed"
                                ascending:NO
                            withPredicate:[NSPredicate predicateWithFormat:@"userID IN %@", self.objectIDs]
                                  groupBy:nil
                                 delegate:self
                                inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                                  configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                                      MRSLUser *user = item;
                                                                      MRSLUserFollowTableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserFollowCellKey];
                                                                      userCell.user = user;
                                                                      userCell.pipeView.hidden = (indexPath.row == count - 1);
                                                                      return userCell;
                                                                  }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - MRSLTableViewDataSource Delegate

- (void)tableViewDataSource:(UITableView *)tableView didSelectItem:(id)item {
    MRSLUser *user = item;
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
    profileVC.user = user;
    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

@end
