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
#import "MRSLTableView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselListViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet MRSLTableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *morselsFetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSMutableArray *morsels;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *morselIDs;

@end

@implementation MRSLMorselListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.morselIDs =  [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"currentuser_draft_morselIDs"] ?: [NSMutableArray array];

    self.title = @"Drafts";

    self.morsels = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
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

    [self.tableView setEmptyStateTitle:@"None yet. Create a new morsel below."];
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

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.tableView toggleLoading:loading];
}

- (void)reloadContent {
    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

- (void)setupFetchRequest {
    self.morselsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"lastUpdatedDate"
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
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getMorselsForUser:nil
                                     withMaxID:nil
                                     orSinceID:nil
                                      andCount:nil
                                    onlyDrafts:YES
                                       success:^(NSArray *responseArray) {
                                           [weakSelf.refreshControl endRefreshing];
                                           weakSelf.morselIDs = [responseArray mutableCopy];
                                           [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                     forKey:@"currentuser_draft_morselIDs"];
                                           [weakSelf setupFetchRequest];
                                           [weakSelf populateContent];
                                           weakSelf.loading = NO;
                                       } failure:^(NSError *error) {
                                           [weakSelf.refreshControl endRefreshing];
                                           weakSelf.loading = NO;
                                       }];
}

- (void)loadMore {
    if (_loadingMore || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more user morsels");
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:[_morselIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getMorselsForUser:nil
                                     withMaxID:@([lastMorsel morselIDValue] - 1)
                                     orSinceID:nil
                                      andCount:@(12)
                                    onlyDrafts:YES
                                       success:^(NSArray *responseArray) {
                                           if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                           DDLogDebug(@"%lu user morsels added", (unsigned long)[responseArray count]);
                                           if (weakSelf) {
                                               if ([responseArray count] > 0) {
                                                   [weakSelf.morselIDs addObjectsFromArray:responseArray];
                                                   [[NSUserDefaults standardUserDefaults] setObject:weakSelf.morselIDs
                                                                                             forKey:@"currentuser_draft_morselIDs"];
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

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel"
                                 properties:@{@"view": @"Drafts",
                                              @"morsel_id": NSNullIfNil(morsel.morselID),
                                              @"morsel_draft": (morsel.draftValue) ? @"true" : @"false"}];
    MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLMorselEditViewController"];
    editMorselVC.morselID = morsel.morselID;
    editMorselVC.shouldPresentMediaCapture = NO;

    [self.navigationController pushViewController:editMorselVC
                                         animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.f) {
        [self loadMore];
    }
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
