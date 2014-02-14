//
//  DraftsViewController.m
//  Morsel
//
//  Created by Javier Otero on 2/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "DraftsViewController.h"

#import "CreateMorselViewController.h"
#import "MorselUploadCollectionViewCell.h"
#import "MorselUploadFailureCollectionViewCell.h"
#import "PostMorselCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface DraftsViewController ()
<NSFetchedResultsControllerDelegate,
UIAlertViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITextFieldDelegate>

@property (nonatomic) int postID;

@property (nonatomic, weak) IBOutlet UICollectionView *draftMorselsCollectionView;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (nonatomic, strong) NSMutableArray *feedMorsels;
@property (nonatomic, strong) NSMutableArray *uploadingMorsels;
@property (nonatomic, strong) NSMutableArray *morsels;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSFetchedResultsController *draftFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *uploadingMorselsFetchedResultsController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation DraftsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.feedMorsels = [NSMutableArray array];
    self.uploadingMorsels = [NSMutableArray array];
    self.morsels = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshDrafts)
              forControlEvents:UIControlEventValueChanged];

    [self.draftMorselsCollectionView addSubview:_refreshControl];
    self.draftMorselsCollectionView.alwaysBounceVertical = YES;

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

    if (_selectedIndexPath) [_draftMorselsCollectionView deselectItemAtIndexPath:_selectedIndexPath
                                                                        animated:YES];

    if (![MRSLUser currentUser] || self.draftFetchedResultsController) return;

    [self setupFeedFetchRequest];
    [self populateContent];
    [self refreshDrafts];
}

#pragma mark - Notification Methods

- (void)morselUploaded:(NSNotification *)notification {
    MRSLMorsel *uploadedMorsel = notification.object;
    if (uploadedMorsel.draftValue) {
        [self refreshDrafts];
    }
}

- (void)localContentPurged {
    [NSFetchedResultsController deleteCacheWithName:@"Home"];

    self.draftFetchedResultsController.delegate = nil;
    self.uploadingMorselsFetchedResultsController.delegate = nil;

    self.draftFetchedResultsController = nil;
    self.uploadingMorselsFetchedResultsController = nil;
}

- (void)localContentRestored {
    [self.feedMorsels removeAllObjects];
    [self.uploadingMorsels removeAllObjects];
    [self.morsels removeAllObjects];

    [self setupFeedFetchRequest];
    [self populateContent];

    self.activityView.hidden = YES;
}

#pragma mark - Private Methods

- (void)setupFeedFetchRequest {
    if (_draftFetchedResultsController || _uploadingMorselsFetchedResultsController) return;

    MRSLUser *user = [MRSLUser currentUser];

    NSPredicate *userDraftsPredicate = [NSPredicate predicateWithFormat:@"(post.creator.userID == %i) AND (draft == YES) AND (isUploading == NO) AND (didFailUpload == NO)", user.userIDValue];

    self.draftFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                               ascending:NO
                                                           withPredicate:userDraftsPredicate
                                                                 groupBy:nil
                                                                delegate:self
                                                               inContext:[NSManagedObjectContext MR_defaultContext]];

    NSPredicate *uploadingMorselPredicate = [NSPredicate predicateWithFormat:@"draft == YES AND (isUploading == YES OR didFailUpload == YES)"];

    self.uploadingMorselsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                          ascending:NO
                                                                      withPredicate:uploadingMorselPredicate
                                                                            groupBy:nil
                                                                           delegate:self
                                                                          inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;

    [_draftFetchedResultsController performFetch:&fetchError];
    [_uploadingMorselsFetchedResultsController performFetch:&fetchError];

    if (_draftFetchedResultsController) {
        [self.feedMorsels removeAllObjects];
        [self.feedMorsels addObjectsFromArray:[_draftFetchedResultsController fetchedObjects]];
    }

    if (_uploadingMorselsFetchedResultsController) {
        [self.uploadingMorsels removeAllObjects];
        [self.uploadingMorsels addObjectsFromArray:[_uploadingMorselsFetchedResultsController fetchedObjects]];
        [self.draftMorselsCollectionView scrollRectToVisible:CGRectMake(0.f, 0.f, 5.f, 5.f)
                                                    animated:YES];
    }

    [self.morsels removeAllObjects];
    [self.morsels addObjectsFromArray:_uploadingMorsels];
    [self.morsels addObjectsFromArray:_feedMorsels];

    [self.draftMorselsCollectionView reloadData];
}

#pragma mark - Action Methods

- (void)refreshDrafts {
    self.activityView.hidden = NO;

    [_appDelegate.morselApiService getUserPosts:[MRSLUser currentUser]
                                  includeDrafts:YES
                                        success:^(NSArray *responseArray)
     {
         if ([responseArray count] > 0) {
             DDLogDebug(@"%lu draft posts available.", (unsigned long)[responseArray count]);
         } else {
             DDLogDebug(@"No draft posts available");
         }
         [_refreshControl endRefreshing];
     } failure: ^(NSError * error) {
         DDLogError(@"Error loading draft posts: %@", error.userInfo);
         [_refreshControl endRefreshing];
     }];
}

- (IBAction)displaySideBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLShouldDisplaySideBarNotification
                                                        object:@YES];
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
        PostMorselCollectionViewCell *postMorselCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostMorselCell"
                                                                                                 forIndexPath:indexPath];
        postMorselCell.morsel = morsel;
        feedCell = postMorselCell;
    } else if (morsel.isUploadingValue && !morsel.didFailUploadValue) {
        MorselUploadCollectionViewCell *uploadCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UploadProgressCell"
                                                                                               forIndexPath:indexPath];
        uploadCell.morsel = morsel;

        feedCell = uploadCell;
    } else if (!morsel.isUploadingValue && morsel.didFailUploadValue) {
        MorselUploadFailureCollectionViewCell *uploadCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UploadFailCell"
                                                                                                      forIndexPath:indexPath];
        uploadCell.morsel = morsel;

        feedCell = uploadCell;
    }

    return feedCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];

    CreateMorselViewController *createMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"CreateMorselViewController"];
    createMorselVC.morsel = morsel;

    [self.navigationController pushViewController:createMorselVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    CGSize morselCellSize = CGSizeMake(320.f, (!morsel.isUploadingValue && !morsel.didFailUploadValue) ? 60.f : 50.f);
    return morselCellSize;
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
