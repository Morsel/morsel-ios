//
//  MRSLModalLikesViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalLikersViewController.h"

#import "MRSLAPIService+Like.h"

#import "MRSLTableView.h"
#import "MRSLTableViewDataSource.h"
#import "MRSLUserFollowTableViewCell.h"
#import "MRSLProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLModalLikersViewController ()
<MRSLTableViewDataSourceDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation MRSLModalLikersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"morsel_likers";
    self.emptyStateString = @"No likes";

    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [_appDelegate.apiService getMorselLikers:strongSelf.morsel
                                            page:page
                                           count:nil
                                         success:^(NSArray *responseArray) {
                                             remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                         } failure:^(NSError *error) {
                                             remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                         }];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                      animated:YES];
        self.selectedIndexPath = nil;
    }
}

#pragma mark - Private Methods

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%@_likerIDs", _morsel.morselID];
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
        MRSLUserFollowTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserFollowCellKey];
        userCell.user = user;
        userCell.pipeView.hidden = (indexPath.row == count - 1);

        return userCell;
    }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - MRSLTableViewDataSource Delegate

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
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
