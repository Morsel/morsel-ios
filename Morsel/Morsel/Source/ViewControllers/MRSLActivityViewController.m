//
//  MRSLActivityViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityViewController.h"

#import "MRSLActivity.h"
#import "MRSLItem.h"
#import "MRSLUser.h"
#import "MRSLActivityCollectionViewCell.h"
#import "MRSLArrayDataSource.h"

@interface MRSLActivityViewController ()
<UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *nullStateView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *activityIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) MRSLArrayDataSource *arrayDataSource;

@end

@implementation MRSLActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.activityIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"MRSLActivityViewController_activityIDs"] ?: [NSArray array];

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
                                                       [cell setActivity:item];
                                                       if (indexPath.row != count) {
                                                           [cell setBorderWithDirections:MRSLBorderSouth
                                                                             borderWidth:1.0f
                                                                          andBorderColor:[UIColor morselLightOffColor]];
                                                       }
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
    self.fetchedResultsController = [MRSLActivity MR_fetchAllSortedBy:@"creationDate"
                                                                      ascending:NO
                                                                  withPredicate:[NSPredicate predicateWithFormat:@"activityID IN %@", _activityIDs]
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
    [_appDelegate.itemApiService getUserActivitiesForUser:[MRSLUser currentUser]
                                                      maxID:nil
                                                  orSinceID:nil
                                                   andCount:nil
                                                    success:^(NSArray *responseArray) {
                                                        weakSelf.activityIDs = responseArray;
                                                        [[NSUserDefaults standardUserDefaults] setObject:responseArray forKey:@"MRSLActivityViewController_activityIDs"];
                                                        [weakSelf setupFetchRequest];
                                                        [weakSelf populateContent];
                                                    } failure:nil];
}


#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLActivity *activity = [self.arrayDataSource itemAtIndexPath:indexPath];
    MRSLItem *item = activity.item;

    NSLog(@"Create event and send user to Morsel Details view");
    [[MRSLEventManager sharedManager] track:@"Tapped Activity"
                                 properties:@{@"view": @"My Activty",
                                              @"action_type": NSNullIfNil(activity.actionType),
                                              @"activity_id": NSNullIfNil(activity.activityID),
                                              @"item_id": NSNullIfNil(item.itemID)}];

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
