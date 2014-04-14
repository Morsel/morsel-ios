//
//  MRSLMorselListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselAddViewController.h"

#import "MRSLMorselCollectionViewCell.h"
#import "MRSLStatusHeaderCollectionReusableView.h"
#import "MRSLMorselAddTitleViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLMorselListViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselAddViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate,
MRSLStatusHeaderCollectionReusableViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *morselCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *createMorselButton;
@property (weak, nonatomic) IBOutlet UIView *nullStateView;
@property (weak, nonatomic) IBOutlet UIView *existingPromptView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSFetchedResultsController *morselsFetchedResultsController;
@property (strong, nonatomic) NSMutableDictionary *morselsDictionary;
@property (strong, nonatomic) NSMutableArray *draftMorsels;
@property (strong, nonatomic) NSMutableArray *publishedMorsels;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLMorselAddViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.draftMorsels = [NSMutableArray array];
    self.publishedMorsels = [NSMutableArray array];
    self.morselsDictionary = [NSMutableDictionary dictionary];

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

    if (![MRSLUser currentUser] || self.morselsFetchedResultsController) return;

    [self setupMorselsFetchRequest];
    [self populateContent];
    [self refreshMorsels];
}

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

    NSPredicate *draftsPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLMorsel *evaluatedMorsel, NSDictionary *bindings) {
        return evaluatedMorsel.draftValue;
    }];
    NSPredicate *publishedPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLMorsel *evaluatedMorsel, NSDictionary *bindings) {
        return !evaluatedMorsel.draftValue;
    }];

    [self.draftMorsels removeAllObjects];
    [self.publishedMorsels removeAllObjects];
    [self.morselsDictionary removeAllObjects];

    [self.draftMorsels addObjectsFromArray:[[_morselsFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:draftsPredicate]];
    [self.publishedMorsels addObjectsFromArray:[[_morselsFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:publishedPredicate]];

    if ([_draftMorsels count] > 0) [self.morselsDictionary setObject:_draftMorsels
                                                          forKey:@"Drafts"];
    if ([_publishedMorsels count] > 0) [self.morselsDictionary setObject:_publishedMorsels
                                                              forKey:@"Published"];

    _nullStateView.hidden = ([_morselsDictionary count] != 0);
    _existingPromptView.hidden = ([_morselsDictionary count] == 0);
    _createMorselButton.hidden = ([_morselsDictionary count] == 0);

    [self.morselCollectionView reloadData];
}

- (NSMutableArray *)morselArrayForIndexPath:(NSIndexPath *)indexPath {
    NSString *keyForIndex = [[_morselsDictionary allKeys] objectAtIndex:indexPath.section];
    NSMutableArray *morselsArray = ([keyForIndex isEqualToString:@"Drafts"] ? _draftMorsels : _publishedMorsels);
    return morselsArray;
}

- (void)refreshMorsels {
    [_appDelegate.itemApiService getUserMorsels:[MRSLUser currentUser]
                                  includeDrafts:YES
                                        success:^(NSArray *responseArray) {
                                            [_refreshControl endRefreshing];
                                        } failure:^(NSError *error) {
                                            [_refreshControl endRefreshing];
                                        }];
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
    return [_morselsDictionary count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_morselsDictionary count] == 0) {
        return 0;
    }
    NSString *keyForIndex = [[_morselsDictionary allKeys] objectAtIndex:section];
    NSUInteger morselsCount = [[_morselsDictionary objectForKey:keyForIndex] count];
    return (morselsCount > MRSLMaximumMorselsToDisplayInMorselAdd && [keyForIndex isEqualToString:@"Published"]) ? MRSLMaximumMorselsToDisplayInMorselAdd : morselsCount;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    MRSLStatusHeaderCollectionReusableView *reusableStatusView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                    withReuseIdentifier:@"ruid_StatusHeaderCell"
                                                                                                           forIndexPath:indexPath];
    if ([_morselsDictionary count] == 0) {
        reusableStatusView.hidden = YES;
        reusableStatusView.delegate = nil;
        return reusableStatusView;
    } else {
        reusableStatusView.hidden = NO;
        reusableStatusView.delegate = self;
    }
    NSString *keyForIndex = [[_morselsDictionary allKeys] objectAtIndex:indexPath.section];
    reusableStatusView.viewAllButton.hidden = ([[_morselsDictionary objectForKey:keyForIndex] count] <= MRSLMaximumMorselsToDisplayInMorselAdd ||
                                               [keyForIndex isEqualToString:@"Drafts"]);
    reusableStatusView.statusLabel.text = [[_morselsDictionary allKeys] objectAtIndex:indexPath.section];
    return reusableStatusView;
}

- (MRSLMorselCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                        cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [[self morselArrayForIndexPath:indexPath] objectAtIndex:indexPath.row];

    MRSLMorselCollectionViewCell *morselCell = [self.morselCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselCell"
                                                                                              forIndexPath:indexPath];
    morselCell.morsel = morsel;

    // Last one hides pipe
    morselCell.morselPipeView.hidden = (indexPath.row == [[self morselArrayForIndexPath:indexPath] count] - 1);

    return morselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [[self morselArrayForIndexPath:indexPath] objectAtIndex:indexPath.row];
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

#pragma mark - MRSLStatusHeaderCollectionReusableViewDelegate Methods

- (void)statusHeaderDidSelectViewAllForType:(MRSLMorselStatusType)statusType {
    [[MRSLEventManager sharedManager] track:@"Tapped View All"
                                 properties:@{@"view": @"Morsel Add"}];
    MRSLMorselListViewController *morselListViewController = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLMorselListViewController"];
    morselListViewController.morselStatusType = statusType;
    morselListViewController.shouldPresentMediaCapture = YES;
    [self.navigationController pushViewController:morselListViewController
                                         animated:YES];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
