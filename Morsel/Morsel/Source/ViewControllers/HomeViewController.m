//
//  HomeViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "HomeViewController.h"

#import "CreateMorselViewController.h"
#import "PostMorselsViewController.h"
#import "MorselFeedCollectionViewCell.h"
#import "MorselDetailViewController.h"
#import "MorselUploadCollectionViewCell.h"
#import "MorselUploadFailureCollectionViewCell.h"
#import "PostMorselsViewController.h"
#import "ProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface HomeViewController ()
<MorselFeedCollectionViewCellDelegate,
NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (nonatomic, strong) NSFetchedResultsController *feedFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *uploadingMorselsFetchedResultsController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *feedMorsels;
@property (nonatomic, strong) NSMutableArray *uploadingMorsels;
@property (nonatomic, strong) NSMutableArray *morsels;

@property (nonatomic, strong) MRSLMorsel *selectedMorsel;
@property (nonatomic, strong) MRSLUser *currentUser;

@end

@implementation HomeViewController

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
                                             selector:@selector(morselUploaded:)
                                                 name:MRSLMorselUploadDidCompleteNotification
                                               object:nil];
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

    if (![MRSLUser currentUser] || self.feedFetchedResultsController) return;

    [self setupFeedFetchRequest];
    [self populateContent];
    [self refreshFeed];
}

#pragma mark - Notification Methods

- (void)morselUploaded:(NSNotification *)notification {
    MRSLMorsel *uploadedMorsel = notification.object;
    if (!uploadedMorsel.draftValue) {
        [self refreshFeed];
    }
}

- (void)localContentPurged {
    [NSFetchedResultsController deleteCacheWithName:@"Home"];

    self.feedFetchedResultsController.delegate = nil;
    self.uploadingMorselsFetchedResultsController.delegate = nil;

    self.feedFetchedResultsController = nil;
    self.uploadingMorselsFetchedResultsController = nil;
}

- (void)localContentRestored {
    if (_feedFetchedResultsController || _uploadingMorselsFetchedResultsController) return;
    
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

    NSPredicate *publishedMorselPredicate = [NSPredicate predicateWithFormat:@"draft == NO AND (isUploading == NO AND didFailUpload == NO)"];

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

    NSPredicate *uploadingMorselPredicate = [NSPredicate predicateWithFormat:@"draft == NO AND (isUploading == YES OR didFailUpload == YES)"];

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

    [_appDelegate.morselApiService getFeedWithSuccess:^(NSArray *responseArray)
     {
         if ([responseArray count] > 0) {
             DDLogDebug(@"%lu feed posts available.", (unsigned long)[responseArray count]);
         } else {
             DDLogDebug(@"No feed posts available");
         }
         [_refreshControl endRefreshing];
     } failure: ^(NSError * error) {
         DDLogError(@"Error loading feed posts: %@", error.userInfo);
         [_refreshControl endRefreshing];
     }];
}

- (IBAction)displaySideBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLShouldDisplaySideBarNotification
                                                        object:@YES];
}

- (IBAction)addMorsel {
    UINavigationController *createMorselNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_CreateMorsel"];

    [self presentViewController:createMorselNC
                       animated:YES
                     completion:nil];
}

- (void)displayUserProfile {
    [[MRSLEventManager sharedManager] track:@"Tapped User Profile Picture"
                          properties:@{@"view": @"HomeViewController",
                                       @"user_id": _currentUser.userID}];
    ProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_ProfileViewController"];
    profileVC.user = _currentUser;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (void)displayMorselDetail {
    [[MRSLEventManager sharedManager] track:@"Tapped Morsel"
                          properties:@{@"view": @"HomeViewController",
                                       @"morsel_id": _selectedMorsel.morselID}];
    MorselDetailViewController *morselDetailVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselDetailViewController"];
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
        MorselFeedCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselCell"
                                                                                                      forIndexPath:indexPath];
        morselCell.delegate = self;
        morselCell.morsel = morsel;

        feedCell = morselCell;
    } else if (morsel.isUploadingValue && !morsel.didFailUploadValue) {
        MorselUploadCollectionViewCell *uploadCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_UploadProgressCell"
                                                                                                        forIndexPath:indexPath];
        uploadCell.morsel = morsel;

        feedCell = uploadCell;
    } else if (!morsel.isUploadingValue && morsel.didFailUploadValue) {
        MorselUploadFailureCollectionViewCell *uploadCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_UploadFailCell"
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

- (void)morselPostCollectionViewCellDidDisplayProgression:(MorselFeedCollectionViewCell *)cell {
    NSIndexPath *cellIndexPath = [self.feedCollectionView indexPathForCell:cell];
    [self.feedCollectionView scrollToItemAtIndexPath:cellIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:YES];
}

- (void)morselPostCollectionViewCellDidSelectEditMorsel:(MRSLMorsel *)morsel {
    UINavigationController *editPostMorselsNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_EditPostMorsels"];

    if ([editPostMorselsNC.viewControllers count] > 0) {
        PostMorselsViewController *postMorselsVC = [editPostMorselsNC.viewControllers firstObject];
        postMorselsVC.post = morsel.post;

        [self.navigationController presentViewController:editPostMorselsNC
                                                animated:YES
                                              completion:nil];
    }
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
