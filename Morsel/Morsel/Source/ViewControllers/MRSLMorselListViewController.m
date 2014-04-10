//
//  MRSLMorselListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselListViewController.h"

#import "MRSLMorselCollectionViewCell.h"
#import "MRSLMorselEditViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselListViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *morselCollectionView;

@property (strong, nonatomic) NSFetchedResultsController *morselsFetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSMutableArray *userMorsels;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLMorselListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"Draft Morsels" : @"Published Morsels";

    self.userMorsels = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshMorsels)
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

    [self setupMorselsFetchRequest];
    [self populateContent];
    [self refreshMorsels];
}

#pragma mark - Private Methods

- (void)setupMorselsFetchRequest {
    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"creator.userID == %i", [MRSLUser currentUser].userIDValue];

    self.morselsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                             ascending:NO
                                                         withPredicate:currentUserPredicate
                                                               groupBy:nil
                                                              delegate:self
                                                             inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;

    [_morselsFetchedResultsController performFetch:&fetchError];

    NSPredicate *morselStatusPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLMorsel *evaluatedMorsel, NSDictionary *bindings) {
        return (_morselStatusType == MRSLMorselStatusTypeDrafts) ? evaluatedMorsel.draftValue : !evaluatedMorsel.draftValue;
    }];

    [self.userMorsels removeAllObjects];
    [self.userMorsels addObjectsFromArray:[[_morselsFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:morselStatusPredicate]];

    [self.morselCollectionView reloadData];
}

- (void)refreshMorsels {
    if (_morselStatusType == MRSLMorselStatusTypeDrafts) {
        [_appDelegate.itemApiService getUserDraftsWithSuccess:nil
                                                        failure:nil];
    } else {
        [_appDelegate.itemApiService getUserMorsels:[MRSLUser currentUser]
                                      includeDrafts:NO
                                            success:^(NSArray *responseArray) {
                                                [_refreshControl endRefreshing];
                                            } failure:^(NSError *error) {
                                                [_refreshControl endRefreshing];
                                            }];
    }
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

    // Last one hides pipe
    morselCell.morselPipeView.hidden = (indexPath.row == [_userMorsels count] - 1);

    return morselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [_userMorsels objectAtIndex:indexPath.row];
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel"
                                 properties:@{@"view": [NSString stringWithFormat:@"%@", (_morselStatusType == MRSLMorselStatusTypeDrafts) ? @"Draft Morsels" : @"Published Morsels"],
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
}

@end
