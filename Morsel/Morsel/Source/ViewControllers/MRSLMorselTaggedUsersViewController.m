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

#import "MRSLTableViewDataSource.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselTaggedUsersViewController ()
<MRSLTableViewDataSourceDelegate>

@end

@implementation MRSLMorselTaggedUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"tagged_users";

    self.emptyStateString = @"No tagged users";

    __weak __typeof(self)weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getTaggedUsersForMorsel:weakSelf.morsel
                                                    page:page
                                                   count:nil
                                                 success:^(NSArray *responseArray) {
                                                     remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                 } failure:^(NSError *error) {
                                                     remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                 }];
    };
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%i_tagged_users_IDs", self.morsel.morselIDValue];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return [MRSLUser MR_fetchAllSortedBy:@"userID"
                               ascending:NO
                           withPredicate:[NSPredicate predicateWithFormat:@"userID IN %@", self.objectIDs]
                                 groupBy:nil
                                delegate:self
                               inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLTableViewDataSource *superDataSource = (MRSLTableViewDataSource *)[super dataSource];
    if (superDataSource) return superDataSource;
    MRSLTableViewDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                                           configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                                               MRSLUser *user = item;
                                                                               MRSLUserFollowTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserFollowCellKey];
                                                                               userCell.user = user;
                                                                               userCell.pipeView.hidden = (indexPath.row == count - 1);

                                                                               return userCell;
                                                                           }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - MRSLTableViewDataSourceDelegate

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item {
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
