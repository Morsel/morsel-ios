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

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL stopLoadingNextPage;

@property (copy, nonatomic) MRSLRemoteRequestBlock remoteRequestBlock;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

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

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicatorView setColor:[UIColor morselDarkContent]];
    [_activityIndicatorView setHidesWhenStopped:YES];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, [self.tableView getWidth], 60.f)];
    [footerView addSubview:_activityIndicatorView];
    [_activityIndicatorView setX:([footerView getWidth] * .5f) - ([_activityIndicatorView getWidth] * .5f)];
    [_activityIndicatorView setY:([footerView getHeight] * .5f) - ([_activityIndicatorView getHeight] * .5f)];

    [self.tableView setTableFooterView:footerView];
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

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    if (loading)
        [_activityIndicatorView startAnimating];
    else
        [_activityIndicatorView stopAnimating];
}

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLActivity MR_fetchAllSortedBy:@"activityID"
                                                            ascending:NO
                                                        withPredicate:[NSPredicate predicateWithFormat:@"activityID IN %@", self.objectIDs]
                                                              groupBy:nil
                                                             delegate:self
                                                            inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)refreshContent {
    [self fetchAPIWithNextPage:NO];
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

- (void)appendObjectIDs:(NSArray *)newObjectIDs {
    self.objectIDs = [self.objectIDs arrayByAddingObjectsFromArray:newObjectIDs];
}

- (void)prependObjectIDs:(NSArray *)newObjectIDs {
    self.objectIDs = [newObjectIDs arrayByAddingObjectsFromArray:self.objectIDs];
}

- (void)loadNextPage {
    if (!self.stopLoadingNextPage) [self fetchAPIWithNextPage:YES];
}

- (void)fetchAPIWithNextPage:(BOOL)nextPage {
    if ([self isLoading] || !self.remoteRequestBlock) return;

    self.loading = YES;
    __weak typeof(self) weakSelf = self;
    self.remoteRequestBlock((nextPage ? [self maxID] : nil), (nextPage ? nil : [self sinceID]), nil, ^(NSArray *objectIDs, NSError *error) {
        if ([objectIDs count] > 0) {
            //  If no data has been loaded or the first new objectID doesn't already exist
            if ([weakSelf.dataSource count] == 0 || ![[objectIDs firstObject] isEqualToNumber:[weakSelf.objectIDs firstObject]]) {
                if (nextPage)
                    [weakSelf appendObjectIDs:[objectIDs copy]];
                else
                    [weakSelf prependObjectIDs:[objectIDs copy]];
                [weakSelf setupFetchRequest];
                [weakSelf populateContent];
            }
        } else if (nextPage) {
            //  Reached the end, stop loading nextPage
            weakSelf.stopLoadingNextPage = YES;
        }
        [weakSelf.refreshControl endRefreshing];
        weakSelf.loading = NO;
    });
}

- (NSNumber *)maxID {
    if ([self.objectIDs count] > 0) {
        return @([[self.objectIDs lastObject] integerValue] - 1);
    } else {
        return nil;
    }
}

- (NSNumber *)sinceID {
    if ([self.objectIDs count] > 0) {
        return [self.objectIDs firstObject];
    } else {
        return nil;
    }
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

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.f) {
        [self loadNextPage];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
