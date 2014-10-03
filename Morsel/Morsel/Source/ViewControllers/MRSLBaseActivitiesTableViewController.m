//
//  MRSLBaseActivitiesTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseActivitiesTableViewController.h"

#import "MRSLAPIService+Activity.h"
#import "MRSLAPIService+Morsel.h"

#import "MRSLActivityTableViewCell.h"
#import "MRSLPlaceViewController.h"
#import "MRSLProfileViewController.h"
#import "MRSLTableViewDataSource.h"
#import "MRSLMorselDetailViewController.h"

#import "MRSLActivity.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLNotification.h"
#import "MRSLUser.h"

#import "UITableView+States.h"

@interface MRSLBaseTableViewController ()
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MRSLTableViewDataSource *dataSource;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (copy, nonatomic) MRSLRemoteRequestBlock remoteRequestBlock;

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;

- (void)registerCellsWithNames:(NSArray *)cellNames;
- (NSFetchedResultsController *)defaultFetchedResultsController;
- (NSString *)emptyStateTitle;

@end


@interface MRSLBaseActivitiesTableViewController ()

@property (strong, nonatomic) NSString *tappedItemEventName;
@property (strong, nonatomic) NSString *tappedItemEventView;

@end

@implementation MRSLBaseActivitiesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self registerCellsWithNames:@[ @"MRSLActivityTableViewCell" ]];

    [self.tableView setEmptyStateTitle:@"No recent activity"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];
    [self.navigationItem setRightBarButtonItem:nil];
}

- (MRSLTableViewDataSource *)dataSource {
    MRSLTableViewDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;

    MRSLTableViewDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                                           configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                                               UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDActivityTableViewCellKey
                                                                                                                                       forIndexPath:indexPath];
                                                                               if ([item isKindOfClass:[MRSLActivity class]])
                                                                                   [(MRSLActivityTableViewCell *)cell setActivity:item];
                                                                               else if ([item isKindOfClass:[MRSLNotification class]])
                                                                                   [(MRSLActivityTableViewCell *)cell setActivity:[item activity]];
                                                                               return cell;
                                                                           }];

    [self setDataSource:newDataSource];
    return newDataSource;
}

- (void)displayUserFeedWithMorsel:(MRSLMorsel *)morsel {
    MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

- (void)displayPlace:(MRSLPlace *)place {
    MRSLPlaceViewController *placeVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlaceViewControllerKey];
    placeVC.place = place;
    [self.navigationController pushViewController:placeVC
                                         animated:YES];
}

- (void)displayUser:(MRSLUser *)user {
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
    profileVC.user = user;
    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (void)showMorselForActivity:(MRSLActivity *)activity {
    MRSLItem *itemSubject = activity.itemSubject;

    if (itemSubject.morsel) {
        [self displayUserFeedWithMorsel:itemSubject.morsel];
    } else if (itemSubject.morsel_id) {
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService getMorsel:nil
                                  orWithID:itemSubject.morsel_id
                                   success:^(id responseObject) {
                                       if ([responseObject isKindOfClass:[MRSLMorsel class]]) {
                                           [weakSelf displayUserFeedWithMorsel:responseObject];
                                       }
                                   } failure:nil];
    }
}

- (void)showReceiverForActivity:(MRSLActivity *)activity {
    if ([activity hasPlaceSubject]) {
        MRSLPlace *placeSubject = activity.placeSubject;
        [self displayPlace:placeSubject];
    } else if ([activity hasUserSubject]) {
        MRSLUser *userSubject = [activity.userSubject isCurrentUser] ? activity.creator : activity.userSubject;
        [self displayUser:userSubject];
    }
}


#pragma mark - MRSLBaseTableViewController Methods

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return [MRSLActivity MR_fetchAllSortedBy:@"activityID"
                                   ascending:NO
                               withPredicate:[NSPredicate predicateWithFormat:@"activityID IN %@", self.objectIDs]
                                     groupBy:nil
                                    delegate:self
                                   inContext:[NSManagedObjectContext MR_defaultContext]];

}


#pragma mark - MRSLTableViewDataSourceDelegate

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item {
    MRSLActivity *activity = nil;

    if ([item isKindOfClass:[MRSLActivity class]]) {
        activity = item;
        if (activity.notification) [activity.notification API_markRead];
    } else if ([item isKindOfClass:[MRSLNotification class]]) {
        [item API_markRead];
        activity = [item activity];
    }

    [[MRSLEventManager sharedManager] track:self.tappedItemEventName
                                 properties:@{@"_view": self.tappedItemEventView,
                                              @"action_type": NSNullIfNil(activity.actionType),
                                              @"activity_id": NSNullIfNil(activity.activityID),
                                              @"subject_type": NSNullIfNil(activity.subjectType),
                                              @"subject_id": NSNullIfNil(activity.subjectID)}];

    if ([activity.actionType isEqualToString:@"Follow"]) {
        [self showReceiverForActivity:activity];
    } else if ([activity.actionType isEqualToString:@"Comment"] || [activity.actionType isEqualToString:@"Like"]) {
        [self showMorselForActivity:activity];
    }
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

@end
