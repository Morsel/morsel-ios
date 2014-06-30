//
//  MRSLMorselListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselAddViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLMorselCollectionViewCell.h"
#import "MRSLMorselAddTitleViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLMorselListViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselAddViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UICollectionView *morselCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *createMorselButton;
@property (weak, nonatomic) IBOutlet UIView *nullStateView;
@property (weak, nonatomic) IBOutlet UIView *existingPromptView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSFetchedResultsController *morselsFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *draftMorsels;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *morselIDs;

@end

@implementation MRSLMorselAddViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.user = [MRSLUser currentUser];
    self.morselIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_draft_morselIDs", _user.username]] ?: [NSMutableArray array];

    self.draftMorsels = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.morselCollectionView addSubview:_refreshControl];
    self.morselCollectionView.alwaysBounceVertical = YES;

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

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (_skipToAddTitle) {
        self.skipToAddTitle = NO;
        [self performSegueWithIdentifier:@"seg_MorselAddTitle"
                                  sender:nil];
    }

    if (_selectedIndexPath) {
        [self.morselCollectionView deselectItemAtIndexPath:_selectedIndexPath
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

    NSPredicate *draftsPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLMorsel *evaluatedMorsel, NSDictionary *bindings) {
        return evaluatedMorsel.draftValue;
    }];

    [self.draftMorsels removeAllObjects];

    [self.draftMorsels addObjectsFromArray:[[_morselsFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:draftsPredicate]];

    _nullStateView.hidden = ([_draftMorsels count] != 0);
    _existingPromptView.hidden = ([_draftMorsels count] == 0);
    _createMorselButton.hidden = ([_draftMorsels count] == 0);

    [self.morselCollectionView reloadData];
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.refreshing = YES;
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
                                                                                     forKey:[NSString stringWithFormat:@"%@_draft_morselIDs", _user.username]];
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
                                                                                             forKey:[NSString stringWithFormat:@"%@_draft_morselIDs", _user.username]];
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

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"seg_MorselAddTitle"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Add a Morsel to a New Morsel"
                                     properties:@{@"view": @"Add Morsel"}];
        MRSLMorselAddTitleViewController *addTitleVC = [segue destinationViewController];
        addTitleVC.isUserEditingTitle = NO;
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_draftMorsels count];
}

- (MRSLMorselCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                          cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_draftMorsels objectAtIndex:indexPath.row];
    MRSLMorselCollectionViewCell *morselCell = [self.morselCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselCell"
                                                                                                    forIndexPath:indexPath];
    morselCell.morsel = morsel;
    morselCell.morselPipeView.hidden = (indexPath.row == [_draftMorsels count] - 1);
    return morselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [_draftMorsels objectAtIndex:indexPath.row];
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel"
                                 properties:@{@"view": @"Morsel Add",
                                              @"morsel_id": NSNullIfNil(morsel.morselID),
                                              @"morsel_draft": (morsel.draftValue) ? @"true" : @"false"}];
    MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLMorselEditViewController"];
    editMorselVC.morselID = morsel.morselID;
    editMorselVC.shouldPresentMediaCapture = YES;
    [self.navigationController pushViewController:editMorselVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Morsel add detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.f) {
        [self loadMore];
    }
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
