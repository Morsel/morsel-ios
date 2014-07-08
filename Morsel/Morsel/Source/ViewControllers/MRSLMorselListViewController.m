//
//  MRSLMorselListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselListViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLMorselTableViewCell.h"
#import "MRSLMorselEditViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselListViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *morselsFetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSMutableArray *morsels;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *morselIDs;

@end

@implementation MRSLMorselListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.user = [MRSLUser currentUser];
    self.morselIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_%@_morselIDs", _user.username, (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"draft" : @"publish"]] ?: [NSMutableArray array];

    self.title = (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"Drafts" : @"Published";

    self.morsels = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
    self.tableView.alwaysBounceVertical = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(morselCreated)
                                                 name:MRSLUserDidCreateMorselNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(morselDeleted:)
                                                 name:MRSLUserDidDeleteMorselNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                                  animated:YES];
        self.selectedIndexPath = nil;
    }

    if (_morselsFetchedResultsController) return;
    [self reloadContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    _morselsFetchedResultsController.delegate = nil;
    _morselsFetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Private Methods

- (void)reloadContent {
    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

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
    self.morsels = [[_morselsFetchedResultsController fetchedObjects] mutableCopy];
    [self.tableView reloadData];
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

#pragma mark - Notification Methods

- (void)morselCreated {
    [self reloadContent];
}

- (void)morselDeleted:(NSNotification *)notification {
    NSNumber *deletedMorselID = notification.object;
    NSNumber *confirmedMorselID = nil;
    for (NSNumber *morselID in self.morselIDs) {
        if ([deletedMorselID intValue] == [morselID intValue]) {
            confirmedMorselID = morselID;
            break;
        }
    }
    [self.morselIDs removeObject:confirmedMorselID];
    [self setupFetchRequest];
    [self populateContent];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_morsels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    MRSLMorselTableViewCell *morselCell = [self.tableView dequeueReusableCellWithIdentifier:@"ruid_MorselCell"];
    morselCell.morsel = morsel;
    morselCell.morselPipeView.hidden = (indexPath.row == [_morsels count] - 1);
    return morselCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRSLMorsel *deletedMorsel = [_morsels objectAtIndex:indexPath.row];
        [[MRSLEventManager sharedManager] track:@"Tapped Delete Morsel"
                                     properties:@{@"view": @"Drafts",
                                                  @"item_count": @([_morsels count]),
                                                  @"morsel_id": NSNullIfNil(deletedMorsel.morselID)}];
        [_morsels removeObject:deletedMorsel];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];
        double delayInSeconds = .4f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_appDelegate.apiService deleteMorsel:deletedMorsel
                                        success:nil
                                          failure:nil];
        });
    }
}

#pragma mark - UICollectionViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
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
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
