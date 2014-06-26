//
//  MRSLMorselListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselListViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLMorselCollectionViewCell.h"
#import "MRSLMorselEditViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselListViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UICollectionView *morselCollectionView;

@property (strong, nonatomic) NSFetchedResultsController *morselsFetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *userMorsels;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *morselIDs;

@end

@implementation MRSLMorselListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.user = [MRSLUser currentUser];
    self.morselIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_%@_morselIDs", _user.username, (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"draft" : @"publish"]] ?: [NSMutableArray array];

    self.title = (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"Drafts" : @"Published";

    self.userMorsels = [NSArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.morselCollectionView addSubview:_refreshControl];
    self.morselCollectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_selectedIndexPath) {
        [self.morselCollectionView deselectItemAtIndexPath:_selectedIndexPath
                                                  animated:YES];
        self.selectedIndexPath = nil;
    }

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    _morselsFetchedResultsController.delegate = nil;
    _morselsFetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.morselsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                 ascending:NO
                                                             withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", _morselIDs]
                                                                   groupBy:nil
                                                                  delegate:self
                                                                 inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_morselsFetchedResultsController performFetch:&fetchError];
    self.userMorsels = [_morselsFetchedResultsController fetchedObjects];
    [self.morselCollectionView reloadData];
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.refreshing = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getMorselsForUser:_user
                                     withMaxID:nil
                                     orSinceID:nil
                                      andCount:@(12)
                                    onlyDrafts:(_morselStatusType == MRSLMorselStatusTypeDrafts)
                                       success:^(NSArray *responseArray) {
                                           [weakSelf.refreshControl endRefreshing];
                                           weakSelf.morselIDs = [responseArray mutableCopy];
                                           [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                     forKey:[NSString stringWithFormat:@"%@_%@_morselIDs", _user.username, (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"draft" : @"publish"]];
                                           [weakSelf setupFetchRequest];
                                           [weakSelf populateContent];
                                           weakSelf.refreshing = NO;
                                       } failure:^(NSError *error) {
                                           [weakSelf.refreshControl endRefreshing];
                                           weakSelf.refreshing = NO;
                                       }];
}

- (void)loadMore {
    if (_loadingMore || !_user || _loadedAll || _refreshing) return;
    self.loadingMore = YES;
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:[_morselIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getMorselsForUser:_user
                                     withMaxID:@([lastMorsel morselIDValue] - 1)
                                     orSinceID:nil
                                      andCount:@(12)
                                    onlyDrafts:(_morselStatusType == MRSLMorselStatusTypeDrafts)
                                       success:^(NSArray *responseArray) {
                                           if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                           DDLogDebug(@"%lu user morsels added", (unsigned long)[responseArray count]);
                                           if (weakSelf) {
                                               if ([responseArray count] > 0) {
                                                   [weakSelf.morselIDs addObjectsFromArray:responseArray];
                                                   [[NSUserDefaults standardUserDefaults] setObject:weakSelf.morselIDs
                                                                                             forKey:[NSString stringWithFormat:@"%@_%@_morselIDs", _user.username, (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"draft" : @"publish"]];
                                                   [weakSelf setupFetchRequest];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [weakSelf populateContent];
                                                   });
                                               }
                                               weakSelf.loadingMore = NO;
                                           }
                                       } failure:^(NSError *error) {
                                           if (weakSelf) weakSelf.loadingMore = NO;
                                       }];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_userMorsels count];
}

- (MRSLMorselCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                          cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_userMorsels objectAtIndex:indexPath.row];
    MRSLMorselCollectionViewCell *morselCell = [self.morselCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselCell"
                                                                                                    forIndexPath:indexPath];
    morselCell.morsel = morsel;
    morselCell.morselPipeView.hidden = (indexPath.row == [_userMorsels count] - 1);
    return morselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [_userMorsels objectAtIndex:indexPath.row];
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel"
                                 properties:@{@"view": [NSString stringWithFormat:@"%@", (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"Drafts" : @"Published"],
                                              @"morsel_id": NSNullIfNil(morsel.morselID),
                                              @"morsel_draft": (morsel.draftValue) ? @"true" : @"false"}];
    MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLMorselEditViewController"];
    editMorselVC.morselID = morsel.morselID;
    editMorselVC.shouldPresentMediaCapture = _shouldPresentMediaCapture;

    [self.navigationController pushViewController:editMorselVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.morselCollectionView.delegate = nil;
    self.morselCollectionView.dataSource = nil;
    [self.morselCollectionView removeFromSuperview];
    self.morselCollectionView = nil;
}

@end
