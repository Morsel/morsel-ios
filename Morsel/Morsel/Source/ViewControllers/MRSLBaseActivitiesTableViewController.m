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
#import "MRSLProfileViewController.h"
#import "MRSLTableViewDataSource.h"
#import "MRSLUserMorselsFeedViewController.h"

#import "MRSLActivity.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLBaseTableViewController ()

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;

- (void)registerCellsWithNames:(NSArray *)cellNames;

@end


@interface MRSLBaseActivitiesTableViewController ()
<MRSLTableViewDataSourceDelegate,
NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MRSLTableViewDataSource *dataSource;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSString *tappedItemEventName;
@property (nonatomic, strong) NSString *tappedItemEventView;

- (void)refreshContent;
- (void)setupFetchRequest;
- (void)populateContent;

@end

@implementation MRSLBaseActivitiesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor morselLightContent];
    [self.refreshControl addTarget:self
                            action:@selector(refreshContent)
                  forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:self.refreshControl];
    self.tableView.alwaysBounceVertical = YES;

    [self registerCellsWithNames:@[ @"MRSLActivityTableViewCell" ]];

    self.dataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                    configureCellBlock:^UITableViewCell *(MRSLActivity *activity, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_MRSLActivityTableViewCell"
                                                                                                                forIndexPath:indexPath];
                                                        [(MRSLActivityTableViewCell *)cell setActivity:activity];
                                                        return cell;
                                                    }];
    [self.tableView setDataSource:_dataSource];
    [self.tableView setDelegate:_dataSource];
    [_dataSource setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (self.fetchedResultsController) return;

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLActivity MR_fetchAllSortedBy:@"activityID"
                                                            ascending:NO
                                                        withPredicate:[NSPredicate predicateWithFormat:@"activityID IN %@", self.objectIDs]
                                                              groupBy:nil
                                                             delegate:self
                                                            inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)refreshContent {
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    [self.dataSource updateObjects:[_fetchedResultsController fetchedObjects]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self.refreshControl endRefreshing];
}

- (void)displayUserFeedWithMorsel:(MRSLMorsel *)morsel {
    MRSLUserMorselsFeedViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLUserMorselsFeedViewController"];
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

- (void)displayUser:(MRSLUser *)user {
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileViewController"];
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
    MRSLUser *userSubject = activity.userSubject;

    [self displayUser:userSubject];
}

#pragma mark - MRSLTableViewDataSourceDelegate

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item {
    MRSLActivity *activity = item;

    [[MRSLEventManager sharedManager] track:self.tappedItemEventName
                                 properties:@{@"view": self.tappedItemEventView,
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

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
