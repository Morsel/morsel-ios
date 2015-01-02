//
//  MRSLExploreSearchViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLExploreSearchViewController.h"

#import "MRSLAPIService+Search.h"

#import "MRSLHashtagKeywordTableViewCell.h"
#import "MRSLFindUsersViewController.h"
#import "MRSLMorselSearchResultsViewController.h"
#import "MRSLProfileViewController.h"
#import "MRSLTableViewDataSource.h"
#import "MRSLTableView.h"
#import "MRSLSectionView.h"
#import "MRSLSegmentedButtonView.h"
#import "MRSLUserFollowTableViewCell.h"
#import "MRSLIconTextTableViewCell.h"

#import "MRSLKeyword.h"
#import "MRSLUser.h"

@interface MRSLBaseRemoteDataSourceViewController (Private)

- (void)populateContent;

@end

@interface MRSLExploreSearchViewController ()
<MRSLTableViewDataSourceDelegate,
MRSLSegmentedButtonViewDelegate>

@property (nonatomic) NSInteger section;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet MRSLSegmentedButtonView *segmentedButtonView;

@property (strong, nonatomic) NSTimer *searchTimer;

@end

@implementation MRSLExploreSearchViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emptyStateString = @"";
    [self setupRemoteRequestBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:self.selectedIndexPath
                                      animated:YES];
        self.selectedIndexPath = nil;
    }
}

- (void)commenceSearch {
    if (_section == 0 && _searchQuery.length > 0)  {
        [self displaySearch];
    }
}

#pragma mark - Set Methods

- (void)setSearchQuery:(NSString *)searchQuery {
    _searchQuery = searchQuery;
    [self resumeTimer];
}

#pragma mark - Private Methods

- (void)resetPredicateFromQuery {
    NSPredicate *predicate = [self predicateForSectionAndQuery];
    NSFetchedResultsController *fetchResultsController = [self defaultFetchedResultsController];
    if (fetchResultsController && predicate) {
        [fetchResultsController.fetchRequest setPredicate:predicate];
    }
    [self populateContent];
}

- (NSPredicate *)predicateForSectionAndQuery {
    NSPredicate *predicate = nil;
    if (_section == 0) {
        predicate = [NSPredicate predicateWithFormat:@"keywordID IN %@", self.objectIDs];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"userID IN %@", self.objectIDs];
    }
    return predicate;
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%li_explore_%@IDs", (long)_section, (_section == 0) ? @"morsel" : @"user"];
}

- (void)displaySearch {
    MRSLMorselSearchResultsViewController *searchVC = [[UIStoryboard exploreStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselSearchResultsViewControllerKey];
    searchVC.searchString = _searchQuery;
    [self.navigationController pushViewController:searchVC
                                         animated:YES];
}

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
    [self setupRemoteRequestBlock];
    [self refreshRemoteContent];
}

- (void)setupRemoteRequestBlock {
    __weak __typeof(self)weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf section] == 0) {
            [_appDelegate.apiService searchHashtagsWithQuery:strongSelf.searchQuery
                                                        page:page
                                                       count:nil
                                                     success:^(NSArray *responseArray) {
                                                         [strongSelf resetPredicateFromQuery];
                                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                     } failure:^(NSError *error) {
                                                         [strongSelf resetPredicateFromQuery];
                                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                     }];
        } else {
            [_appDelegate.apiService searchUsersWithQuery:strongSelf.searchQuery
                                                     page:page
                                                    count:nil
                                                  success:^(NSArray *responseArray) {
                                                      [strongSelf resetPredicateFromQuery];
                                                      remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                  } failure:^(NSError *error) {
                                                      [strongSelf resetPredicateFromQuery];
                                                      remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                  }];
        }
    };
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    if (!self.objectIDs) return nil;
    if (_section == 0) {
        NSPredicate *predicate = [self predicateForSectionAndQuery];
        NSFetchedResultsController *fetchedResultsController = [MRSLKeyword MR_fetchAllSortedBy:@"keywordID"
                                                                                      ascending:NO
                                                                                  withPredicate:predicate
                                                                                        groupBy:nil
                                                                                       delegate:self
                                                                                      inContext:[NSManagedObjectContext MR_defaultContext]];

        return fetchedResultsController;
    } else {
        NSPredicate *predicate = [self predicateForSectionAndQuery];
        NSFetchedResultsController *fetchedResultsController = [MRSLUser MR_fetchAllSortedBy:@"userID"
                                                                                   ascending:NO
                                                                               withPredicate:predicate
                                                                                     groupBy:nil
                                                                                    delegate:self
                                                                                   inContext:[NSManagedObjectContext MR_defaultContext]];
        return fetchedResultsController;
    }
}

- (MRSLTableViewDataSource *)dataSource {
    MRSLTableViewDataSource *superDataSource = (MRSLTableViewDataSource *)[super dataSource];
    if (superDataSource) return superDataSource;

    __weak __typeof(self) weakSelf = self;
    MRSLTableViewDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                                           configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                                               __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                               if (![strongSelf iconTextCellFoundForIndexPath:indexPath]) {
                                                                                   if ([item isKindOfClass:[MRSLUser class]]) {
                                                                                       MRSLUserFollowTableViewCell *userFollowCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDUserFollowCellKey];
                                                                                       userFollowCell.user = (MRSLUser *)item;
                                                                                       userFollowCell.pipeView.hidden = (indexPath.row == [self.dataSource count] - 1);
                                                                                       return userFollowCell;
                                                                                   } else {
                                                                                       MRSLHashtagKeywordTableViewCell *hashtagCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDHashtagKeywordCellKey];
                                                                                       hashtagCell.hashtagKeyword = (MRSLKeyword *)item;
                                                                                       return hashtagCell;
                                                                                   }
                                                                               } else {
                                                                                   MRSLIconTextTableViewCell *iconTextCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDIcontTextCellKey];
                                                                                   iconTextCell.titleLabel.text = (strongSelf.section == 0) ? [NSString stringWithFormat:@"search for \"%@\"", strongSelf.searchQuery] : @"Find friends";
                                                                                   iconTextCell.iconImageView.image = [UIImage imageNamed:(strongSelf.section == 0) ? @"icon-explore-search" : @"icon-explore-find"];
                                                                                   iconTextCell.pipeView.hidden = (strongSelf.section == 1);
                                                                                   return iconTextCell;
                                                                               }
                                                                           }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

- (BOOL)matchesConditionsToDisplayAdditionalSection {
    return ((_section == 0 && [self.searchQuery length] > 2) || (_section == 1 && [self.searchQuery length] == 0));
}

- (BOOL)iconTextCellFoundForIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0 && [self matchesConditionsToDisplayAdditionalSection]);
}

#pragma mark - MRSLSegmentedButtonViewDelegate

- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index {
    self.section = index;

    self.emptyStateString = (index == 0) ? @"" : @"No results found.";
    [self setupRemoteRequestBlock];
    [self refreshRemoteContent];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 1;
    if ([self matchesConditionsToDisplayAdditionalSection]) count++;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSInteger height = 0.f;
    if ([self matchesConditionsToDisplayAdditionalSection] && section == 0) {
        height = 0.f;
    } else {
        height = ([_searchQuery length] > 2) ? 0.f : 34.f;
    }
    return height;
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_section == 0 && [self matchesConditionsToDisplayAdditionalSection]) return 60.f;
    return (_section == 0) ? 44.f : 60.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [MRSLSectionView sectionViewWithTitle:((_section == 0) ? @"Popular hashtags" : @"Suggested users")];
}

#pragma mark - MRSLTableViewDataSourceDelegate

- (NSInteger)tableViewDataSourceNumberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if ([self matchesConditionsToDisplayAdditionalSection] && section == 0) {
        count = 1;
    } else {
        count = [self.dataSource count];
    }
    return count;
}

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndexPath = indexPath;
    if ([self iconTextCellFoundForIndexPath:indexPath]) {
        if (_section == 0) {
            [self displaySearch];
        } else {
            MRSLFindUsersViewController *findFriendsVC = [[UIStoryboard socialStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardFindUsersViewControllerKey];
            [self.navigationController pushViewController:findFriendsVC
                                                 animated:YES];
        }
    } else {
        if ([item isKindOfClass:[MRSLUser class]]) {
            MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
            profileVC.user = (MRSLUser *)item;
            [self.navigationController pushViewController:profileVC
                                                 animated:YES];
        } else if ([item isKindOfClass:[MRSLKeyword class]]) {
            MRSLMorselSearchResultsViewController *hashtagVC = [[UIStoryboard exploreStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselSearchResultsViewControllerKey];
            hashtagVC.hashtagString = [item name];
            [self.navigationController pushViewController:hashtagVC
                                                 animated:YES];
        }
    }
}

@end
