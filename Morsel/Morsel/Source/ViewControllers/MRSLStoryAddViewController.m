//
//  MRSLStoryListViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStoryAddViewController.h"

#import "MRSLStoryCollectionViewCell.h"
#import "MRSLStatusHeaderCollectionReusableView.h"
#import "MRSLStoryAddTitleViewController.h"
#import "MRSLStoryEditViewController.h"
#import "MRSLStoryListViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLStoryAddViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate,
MRSLStatusHeaderCollectionReusableViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSFetchedResultsController *postsFetchedResultsController;
@property (strong, nonatomic) NSMutableDictionary *postsDictionary;
@property (strong, nonatomic) NSMutableArray *draftPosts;
@property (strong, nonatomic) NSMutableArray *publishedPosts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLStoryAddViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.draftPosts = [NSMutableArray array];
    self.publishedPosts = [NSMutableArray array];
    self.postsDictionary = [NSMutableDictionary dictionary];

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

    if (![MRSLUser currentUser] || self.postsFetchedResultsController) return;

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

    NSPredicate *draftsPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLPost *evaluatedPost, NSDictionary *bindings) {
        return evaluatedPost.draftValue;
    }];
    NSPredicate *publishedPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLPost *evaluatedPost, NSDictionary *bindings) {
        return !evaluatedPost.draftValue;
    }];

    [self.draftPosts removeAllObjects];
    [self.publishedPosts removeAllObjects];
    [self.postsDictionary removeAllObjects];

    [self.draftPosts addObjectsFromArray:[[_postsFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:draftsPredicate]];
    [self.publishedPosts addObjectsFromArray:[[_postsFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:publishedPredicate]];

    if ([_draftPosts count] > 0) [self.postsDictionary setObject:_draftPosts
                                                          forKey:@"Drafts"];
    if ([_publishedPosts count] > 0) [self.postsDictionary setObject:_publishedPosts
                                                              forKey:@"Published"];

    [self.postCollectionView reloadData];
}

- (NSMutableArray *)storyArrayForIndexPath:(NSIndexPath *)indexPath {
    NSString *keyForIndex = [[_postsDictionary allKeys] objectAtIndex:indexPath.section];
    NSMutableArray *postsArray = ([keyForIndex isEqualToString:@"Drafts"] ? _draftPosts : _publishedPosts);
    return postsArray;
}

- (void)localContentPurged {
    self.postsFetchedResultsController.delegate = nil;
    self.postsFetchedResultsController = nil;
}

- (void)localContentRestored {
    if (_postsFetchedResultsController) return;

    [_refreshControl endRefreshing];

    [self.draftPosts removeAllObjects];
    [self.publishedPosts removeAllObjects];
    [self.postsDictionary removeAllObjects];

    [self setupPostsFetchRequest];
    [self populateContent];
}

- (void)refreshStories {
    [_appDelegate.morselApiService getUserPosts:[MRSLUser currentUser]
                                  includeDrafts:YES
                                        success:nil
                                        failure:nil];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"seg_StoryAddTitle"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Add a Morsel to a New Story"
                                     properties:@{@"view": @"Add Story"}];
        MRSLStoryAddTitleViewController *addTitleVC = [segue destinationViewController];
        addTitleVC.isUserEditingTitle = NO;
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_postsDictionary count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_postsDictionary count] == 0) {
        return 0;
    }
    NSString *keyForIndex = [[_postsDictionary allKeys] objectAtIndex:section];
    NSUInteger postsCount = [[_postsDictionary objectForKey:keyForIndex] count];
    return (postsCount > MRSLMaximumPostsToDisplayInStoryAdd && [keyForIndex isEqualToString:@"Published"]) ? MRSLMaximumPostsToDisplayInStoryAdd : postsCount;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    MRSLStatusHeaderCollectionReusableView *reusableStatusView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                    withReuseIdentifier:@"ruid_StatusHeaderCell"
                                                                                                           forIndexPath:indexPath];
    if ([_postsDictionary count] == 0) {
        reusableStatusView.hidden = YES;
        reusableStatusView.delegate = nil;
        return reusableStatusView;
    } else {
        reusableStatusView.hidden = NO;
        reusableStatusView.delegate = self;
    }
    NSString *keyForIndex = [[_postsDictionary allKeys] objectAtIndex:indexPath.section];
    reusableStatusView.viewAllButton.hidden = ([[_postsDictionary objectForKey:keyForIndex] count] <= MRSLMaximumPostsToDisplayInStoryAdd ||
                                               [keyForIndex isEqualToString:@"Drafts"]);
    reusableStatusView.statusLabel.text = [[_postsDictionary allKeys] objectAtIndex:indexPath.section];
    return reusableStatusView;
}

- (MRSLStoryCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                        cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLPost *post = [[self storyArrayForIndexPath:indexPath] objectAtIndex:indexPath.row];

    MRSLStoryCollectionViewCell *postCell = [self.postCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PostCell"
                                                                                              forIndexPath:indexPath];
    postCell.post = post;

    // Last one hides pipe
    postCell.postPipeView.hidden = (indexPath.row == [[self storyArrayForIndexPath:indexPath] count] - 1);

    return postCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLPost *post = [[self storyArrayForIndexPath:indexPath] objectAtIndex:indexPath.row];
    [[MRSLEventManager sharedManager] track:@"Tapped Story"
                                 properties:@{@"view": @"Story Add",
                                              @"story_id": NSNullIfNil(post.postID),
                                              @"story_draft": (post.draftValue) ? @"true" : @"false"}];
    MRSLStoryEditViewController *editStoryVC = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLStoryEditViewController"];
    editStoryVC.postID = post.postID;
    editStoryVC.shouldPresentMediaCapture = YES;

    [self.navigationController pushViewController:editStoryVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Story add detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - MRSLStatusHeaderCollectionReusableViewDelegate Methods

- (void)statusHeaderDidSelectViewAllForType:(MRSLStoryStatusType)statusType {
    [[MRSLEventManager sharedManager] track:@"Tapped View All"
                                 properties:@{@"view": @"Story Add"}];
    MRSLStoryListViewController *storyListViewController = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLStoryListViewController"];
    storyListViewController.storyStatusType = statusType;
    storyListViewController.shouldPresentMediaCapture = YES;
    [self.navigationController pushViewController:storyListViewController
                                         animated:YES];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
