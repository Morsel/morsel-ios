//
//  MRSLStoryListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryListViewController.h"

#import "MRSLStoryCollectionViewCell.h"
#import "MRSLStoryEditViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLStoryListViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;

@property (strong, nonatomic) NSFetchedResultsController *postsFetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSMutableArray *userPosts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLStoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = (_storyStatusType == MRSLStoryStatusTypeDrafts) ? @"Draft Stories" : @"Published Stories";

    self.userPosts = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshStories)
              forControlEvents:UIControlEventValueChanged];

    [self.postCollectionView addSubview:_refreshControl];
    self.postCollectionView.alwaysBounceVertical = YES;

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

    if (_selectedIndexPath) {
        [self.postCollectionView deselectItemAtIndexPath:_selectedIndexPath
                                                animated:YES];
        self.selectedIndexPath = nil;
    }

    [self setupPostsFetchRequest];
    [self populateContent];
    [self refreshStories];
}

- (void)setupPostsFetchRequest {
    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"creator.userID == %i", [MRSLUser currentUser].userIDValue];

    self.postsFetchedResultsController = [MRSLPost MR_fetchAllSortedBy:@"creationDate"
                                                             ascending:NO
                                                         withPredicate:currentUserPredicate
                                                               groupBy:nil
                                                              delegate:self
                                                             inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;

    [_postsFetchedResultsController performFetch:&fetchError];

    NSPredicate *postStatusPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLPost *evaluatedPost, NSDictionary *bindings) {
        return (_storyStatusType == MRSLStoryStatusTypeDrafts) ? evaluatedPost.draftValue : !evaluatedPost.draftValue;
    }];

    [self.userPosts removeAllObjects];
    [self.userPosts addObjectsFromArray:[[_postsFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:postStatusPredicate]];

    [self.postCollectionView reloadData];
}

- (void)localContentPurged {
    self.postsFetchedResultsController.delegate = nil;
    self.postsFetchedResultsController = nil;
}

- (void)localContentRestored {
    if (_postsFetchedResultsController) return;

    [_refreshControl endRefreshing];

    [self.userPosts removeAllObjects];

    [self setupPostsFetchRequest];
    [self populateContent];
}

- (void)refreshStories {
    if (_storyStatusType == MRSLStoryStatusTypeDrafts) {
        [_appDelegate.morselApiService getUserDraftsWithSuccess:nil
                                                        failure:nil];
    } else {
        [_appDelegate.morselApiService getUserPosts:[MRSLUser currentUser]
                                      includeDrafts:NO
                                            success:nil
                                            failure:nil];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_userPosts count];
}

- (MRSLStoryCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                        cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLPost *post = [_userPosts objectAtIndex:indexPath.row];

    MRSLStoryCollectionViewCell *postCell = [self.postCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PostCell"
                                                                                              forIndexPath:indexPath];
    postCell.post = post;

    // Last one hides pipe
    postCell.postPipeView.hidden = (indexPath.row == [_userPosts count] - 1);

    return postCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLPost *post = [_userPosts objectAtIndex:indexPath.row];
    MRSLStoryEditViewController *editStoryVC = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLStoryEditViewController"];
    editStoryVC.postID = post.postID;
    editStoryVC.shouldPresentMediaCapture = YES;

    [self.navigationController pushViewController:editStoryVC
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
