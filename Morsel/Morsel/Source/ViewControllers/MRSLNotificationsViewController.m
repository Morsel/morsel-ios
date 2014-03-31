//
//  MRSLNotificationsViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLNotificationsViewController.h"

#import "MRSLNotification.h"
#import "MRSLActivity.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"
#import "MRSLActivityCollectionViewCell.h"
#import "MRSLArrayDataSource.h"

@interface MRSLNotificationsViewController ()
<UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *nullStateView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *notificationIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) MRSLArrayDataSource *arrayDataSource;

@end

@implementation MRSLNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.notificationIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"MRSLNotificationsViewController_notificationIDs"] ?: [NSArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.collectionView addSubview:_refreshControl];
    self.collectionView.alwaysBounceVertical = YES;

    self.arrayDataSource = [[MRSLArrayDataSource alloc] initWithItems:nil
                                                       cellIdentifier:@"ruid_ActivityCell"
                                                   configureCellBlock:^(id cell, id item, NSIndexPath *indexPath, NSUInteger count) {
                                                       //  NOTE: Since the only payload type returned by Notifications
                                                       //   right now is an Activity, reuse the ActivityCell. Eventually
                                                       //   when other notifications (like announcements, events, etc.)
                                                       //   are introduced this will need to be changed.
                                                       [cell setActivity:[item activity]];
                                                   }];
    [self.collectionView setDataSource:_arrayDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (_selectedIndexPath) {
        [self.collectionView deselectItemAtIndexPath:_selectedIndexPath
                                            animated:YES];
        self.selectedIndexPath = nil;
    }

    if (self.fetchedResultsController) return;

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}


#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLNotification MR_fetchAllSortedBy:@"creationDate"
                                                            ascending:NO
                                                        withPredicate:[NSPredicate predicateWithFormat:@"notificationID IN %@", _notificationIDs]
                                                              groupBy:nil
                                                             delegate:self
                                                            inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    [self.arrayDataSource updateItems:[_fetchedResultsController fetchedObjects]];
    [self.collectionView reloadData];
    self.nullStateView.hidden = ([self.arrayDataSource count] > 0);
    [_refreshControl endRefreshing];
}

- (void)refreshContent {
    __weak typeof(self) weakSelf = self;
    [_appDelegate.morselApiService getUserNotificationsForUser:[MRSLUser currentUser]
                                                         maxID:nil
                                                     orSinceID:nil
                                                      andCount:nil
                                                       success:^(NSArray *responseArray) {
                                                           [[NSUserDefaults standardUserDefaults] setObject:responseArray forKey:@"MRSLNotificationsViewController_notificationIDs"];
                                                           [weakSelf setupFetchRequest];
                                                           [weakSelf populateContent];
                                                       } failure:nil];
}


#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLNotification *notification = [self.arrayDataSource itemAtIndexPath:indexPath];
    MRSLActivity *activity = notification.activity;
    MRSLMorsel *morsel = activity.morsel;

    NSLog(@"Create event and send user to Morsel Details view");
    [[MRSLEventManager sharedManager] track:@"Tapped Notification"
                                 properties:@{@"view": @"Notifications",
                                              @"notification_id": NSNullIfNil(notification.notificationID),
                                              @"action_type": NSNullIfNil(activity.actionType),
                                              @"activity_id": NSNullIfNil(activity.activityID),
                                              @"morsel_id": NSNullIfNil(morsel.morselID)}];

    //  TODO: Implement going to Morsel Detail view when that screen is implemented
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
