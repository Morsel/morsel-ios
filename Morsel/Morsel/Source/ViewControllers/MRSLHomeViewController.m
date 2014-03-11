//
//  HomeViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLHomeViewController.h"

#import "MRSLFeedCollectionViewCell.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLUploadCollectionViewCell.h"
#import "MRSLUploadFailureCollectionViewCell.h"
#import "MRSLProfileViewController.h"
#import "MRSLStoryEditViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLHomeViewController ()
<MorselFeedCollectionViewCellDelegate,
NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *uploadingMorselsFetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *feedMorsels;
@property (strong, nonatomic) NSMutableArray *uploadingMorsels;
@property (strong, nonatomic) NSMutableArray *morsels;

@property (strong, nonatomic) MRSLMorsel *selectedMorsel;
@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLHomeViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.feedCollectionView.accessibilityLabel = @"Feed";

    self.feedMorsels = [NSMutableArray array];
    self.uploadingMorsels = [NSMutableArray array];
    self.morsels = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshFeed)
              forControlEvents:UIControlEventValueChanged];

    [self.feedCollectionView addSubview:_refreshControl];
    self.feedCollectionView.alwaysBounceVertical = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentPurged)
                                                 name:MRSLServiceWillPurgeDataNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentRestored)
                                                 name:MRSLServiceWillRestoreDataNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![MRSLUser currentUser] || _feedFetchedResultsController) return;

    [self setupFeedFetchRequest];
    [self populateContent];
    [self refreshFeed];
}

#pragma mark - Notification Methods

- (void)localContentPurged {
    [NSFetchedResultsController deleteCacheWithName:@"Home"];

    self.feedFetchedResultsController.delegate = nil;
    self.uploadingMorselsFetchedResultsController.delegate = nil;

    self.feedFetchedResultsController = nil;
    self.uploadingMorselsFetchedResultsController = nil;
}

- (void)localContentRestored {
    if (_feedFetchedResultsController || _uploadingMorselsFetchedResultsController) return;

    [_refreshControl endRefreshing];

    [self.feedMorsels removeAllObjects];
    [self.uploadingMorsels removeAllObjects];
    [self.morsels removeAllObjects];

    [self setupFeedFetchRequest];
    [self populateContent];

    self.activityView.hidden = YES;
}

#pragma mark - Private Methods

- (void)setupFeedFetchRequest {
    if (_feedFetchedResultsController || _uploadingMorselsFetchedResultsController) return;

    NSPredicate *publishedMorselPredicate = [NSPredicate predicateWithFormat:@"(post.draft == NO) AND (isUploading == NO AND didFailUpload == NO)"];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[MRSLMorsel MR_entityDescription]];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"creationDate"
                                                         ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setPredicate:publishedMorselPredicate];
    [fetchRequest setFetchBatchSize:10];

    self.feedFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:@"Home"];
    _feedFetchedResultsController.delegate = self;

    NSPredicate *uploadingMorselPredicate = [NSPredicate predicateWithFormat:@"(post.draft == NO) AND (isUploading == YES OR didFailUpload == YES)"];

    self.uploadingMorselsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                          ascending:NO
                                                                      withPredicate:uploadingMorselPredicate
                                                                            groupBy:nil
                                                                           delegate:self
                                                                          inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;

    [_feedFetchedResultsController performFetch:&fetchError];
    [_uploadingMorselsFetchedResultsController performFetch:&fetchError];

    if (_feedFetchedResultsController) {
        [self.feedMorsels removeAllObjects];
        [self.feedMorsels addObjectsFromArray:[_feedFetchedResultsController fetchedObjects]];
    }

    if (_uploadingMorselsFetchedResultsController) {
        [self.uploadingMorsels removeAllObjects];
        [self.uploadingMorsels addObjectsFromArray:[_uploadingMorselsFetchedResultsController fetchedObjects]];
        if ([_uploadingMorsels count] > 0) {
            [self.feedCollectionView scrollRectToVisible:CGRectMake(0.f, 0.f, 5.f, 5.f)
                                                animated:YES];
        }
    }

    [self.morsels removeAllObjects];
    [self.morsels addObjectsFromArray:_uploadingMorsels];
    [self.morsels addObjectsFromArray:_feedMorsels];

    [self.feedCollectionView reloadData];
}

#pragma mark - Section Methods

- (void)refreshFeed {
    self.activityView.hidden = NO;

    [_appDelegate.morselApiService getFeedWithSuccess:nil
                                              failure:nil];
}

- (void)displayUserProfile {
    [[MRSLEventManager sharedManager] track:@"Tapped User Profile Picture"
                          properties:@{@"view": @"MRSLHomeViewController",
                                       @"user_id": _currentUser.userID}];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_ProfileViewController"];
    profileVC.user = _currentUser;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (void)displayMorselDetail {
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel"
                          properties:@{@"view": @"MRSLHomeViewController",
                                       @"morsel_id": _selectedMorsel.morselID}];
    MRSLMorselDetailViewController *morselDetailVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselDetailViewController"];
    morselDetailVC.morsel = _selectedMorsel;

    [self.navigationController pushViewController:morselDetailVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_morsels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];

    UICollectionViewCell *feedCell = nil;

    if (!morsel.isUploadingValue && !morsel.didFailUploadValue) {
        MRSLFeedCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselCell"
                                                                                                      forIndexPath:indexPath];
        morselCell.delegate = self;
        morselCell.morsel = morsel;

        feedCell = morselCell;
    } else if (morsel.isUploadingValue && !morsel.didFailUploadValue) {
        MRSLUploadCollectionViewCell *uploadCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_UploadProgressCell"
                                                                                                        forIndexPath:indexPath];
        uploadCell.morsel = morsel;

        feedCell = uploadCell;
    } else if (!morsel.isUploadingValue && morsel.didFailUploadValue) {
        MRSLUploadFailureCollectionViewCell *uploadCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_UploadFailCell"
                                                                                                               forIndexPath:indexPath];
        uploadCell.morsel = morsel;

        feedCell = uploadCell;
    }

    return feedCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    self.selectedMorsel = morsel;

    [self displayMorselDetail];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    return (!morsel.isUploadingValue && !morsel.didFailUploadValue);
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    CGSize morselCellSize = CGSizeMake(320.f, (!morsel.isUploadingValue && !morsel.didFailUploadValue) ? 214.f : 50.f);
    return morselCellSize;
}

#pragma mark - MorselFeedCollectionViewCellDelegate Methods

- (void)morselPostCollectionViewCellDidSelectProfileForUser:(MRSLUser *)user {
    self.currentUser = user;

    [self displayUserProfile];
}

- (void)morselPostCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel {
    self.selectedMorsel = morsel;

    [self displayMorselDetail];
}

- (void)morselPostCollectionViewCellDidDisplayProgression:(MRSLFeedCollectionViewCell *)cell {
    NSIndexPath *cellIndexPath = [self.feedCollectionView indexPathForCell:cell];
    [self.feedCollectionView scrollToItemAtIndexPath:cellIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:YES];
}

- (void)morselPostCollectionViewCellDidSelectEditMorsel:(MRSLMorsel *)morsel {
    MRSLStoryEditViewController *editStoryVC = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLStoryEditViewController"];

    editStoryVC.postID = morsel.post.postID;
    [self.navigationController pushViewController:editStoryVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
