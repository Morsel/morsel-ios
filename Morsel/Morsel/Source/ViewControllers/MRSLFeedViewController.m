//
//  FeedViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLFeedViewController.h"

#import "NSMutableArray+Feed.h"

#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLProfileViewController.h"
#import "MRSLStoryEditViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedViewController ()
<NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;

@property (strong, nonatomic) NSMutableArray *feedPosts;
@property (strong, nonatomic) NSMutableArray *feedIDs;

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLFeedViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.feedCollectionView.accessibilityLabel = @"Feed";

    self.feedPosts = [NSMutableArray array];
    self.feedIDs = [NSMutableArray feedIDArray];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentPurged)
                                                 name:MRSLServiceWillPurgeDataNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentRestored)
                                                 name:MRSLServiceWillRestoreDataNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollFeedToFirst)
                                                 name:MRSLAppShouldDisplayFeedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleLightContent];

    [super viewWillAppear:animated];

    if (![MRSLUser currentUser] || _feedFetchedResultsController) return;

    [self setupFeedFetchRequest];
    [self populateContent];
    [self refreshFeed];
}

#pragma mark - Notification Methods

- (void)localContentPurged {
    [NSFetchedResultsController deleteCacheWithName:@"Feed"];

    self.feedFetchedResultsController.delegate = nil;

    self.feedFetchedResultsController = nil;
}

- (void)localContentRestored {
    if (_feedFetchedResultsController) return;

    [self.feedPosts removeAllObjects];

    [self setupFeedFetchRequest];
    [self populateContent];
}

- (void)scrollFeedToFirst {
    [self.feedCollectionView scrollRectToVisible:CGRectMake(2.f, 2.f, 2.f, 2.f)
                                        animated:NO];
}

#pragma mark - Private Methods

- (void)setupFeedFetchRequest {
    if (_feedFetchedResultsController) return;

    NSPredicate *publishedMorselPredicate = [NSPredicate predicateWithFormat:@"(draft == NO)"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[MRSLPost MR_entityDescription]];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"creationDate"
                                                         ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setPredicate:publishedMorselPredicate];
    [fetchRequest setFetchBatchSize:10];

    self.feedFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:@"Feed"];
    _feedFetchedResultsController.delegate = self;
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_feedFetchedResultsController performFetch:&fetchError];
    if (_feedFetchedResultsController) {
        [self.feedPosts removeAllObjects];
        NSPredicate *feedIDPredicate = [NSPredicate predicateWithFormat:@"postID IN %@", _feedIDs];
        [self.feedPosts addObjectsFromArray:[[_feedFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:feedIDPredicate]];
    }
    [self.feedCollectionView reloadData];
}

#pragma mark - Section Methods

- (void)refreshFeed {
    NSNumber *firstPersistedID = nil;
    NSNumber *lastPersistedID = nil;
    if ([_feedIDs count] > 0) {
        firstPersistedID = [_feedIDs firstObject];
        MRSLPost *lastPost = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                     withValue:[_feedIDs lastObject]];
        lastPersistedID = @([lastPost feedItemIDValue] - 1);
    }
    [_appDelegate.morselApiService getFeedWithMaxID:nil
                                          orSinceID:nil
                                           andCount:nil
                                            success:^(NSArray *responseArray) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.feedIDs removeAllObjects];
                                                    [self.feedIDs addObjectsFromArray:responseArray];
                                                    [self.feedIDs saveFeedIDArray];
                                                    [self populateContent];
                                                    if ([firstPersistedID intValue] != [[self.feedIDs firstObject] intValue]) {
                                                        DDLogDebug(@"New Stories detected!");
                                                    }
                                                });
    } failure:nil];
}

- (void)displayUserProfile {
    [[MRSLEventManager sharedManager] track:@"Tapped Profile Icon"
                          properties:@{@"view": @"Feed",
                                       @"user_id": _currentUser.userID}];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_ProfileViewController"];
    profileVC.user = _currentUser;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_feedPosts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLPost *post = [_feedPosts objectAtIndex:indexPath.row];
    MRSLFeedPanelCollectionViewCell *postPanelCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_FeedPanelCell"
                                                                                               forIndexPath:indexPath];
    [postPanelCell setOwningViewController:self
                                  withPost:post];
    return postPanelCell;
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
