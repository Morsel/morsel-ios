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
UICollectionViewDelegateFlowLayout,
MRSLFeedPanelCollectionViewCellDelegate>

@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL theNewStoriesAvailable;

@property (nonatomic) NSInteger theNewStoriesCount;

@property (weak, nonatomic) IBOutlet UIButton *menuBarButton;
@property (weak, nonatomic) IBOutlet UIButton *addMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *theNewStoriesButton;
@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;

@property (strong, nonatomic) NSMutableArray *feedPosts;
@property (strong, nonatomic) NSMutableArray *feedIDs;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLFeedViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.feedCollectionView.accessibilityLabel = @"Feed";

    self.feedPosts = [NSMutableArray array];
    self.feedIDs = [NSMutableArray feedIDArray];

    [self setupFeedTimer];
    [self toggleNewStoriesButton:NO
                        animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentPurged)
                                                 name:MRSLServiceWillPurgeDataNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentRestored)
                                                 name:MRSLServiceWillRestoreDataNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayPublishedPost:)
                                                 name:MRSLUserDidPublishPostNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideControls)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControls)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspendTimer)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTimer)
                                                 name:UIApplicationWillEnterForegroundNotification
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

- (void)suspendTimer {
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
}

- (void)resumeTimer {
    [self setupFeedTimer];
}

- (void)hideControls {
    [self toggleControls:NO];
}

- (void)showControls {
    [self toggleControls:YES];
}

- (void)toggleControls:(BOOL)shouldDisplay {
    _feedCollectionView.scrollEnabled = shouldDisplay;
    _menuBarButton.enabled = shouldDisplay;
    _addMorselButton.enabled = shouldDisplay;
    [UIView animateWithDuration:.2f animations:^{
        [_menuBarButton setAlpha:shouldDisplay];
        [_addMorselButton setAlpha:shouldDisplay];
    }];
}

- (void)toggleNewStoriesButton:(BOOL)shouldDisplay
                      animated:(BOOL)animated {
    [UIView animateWithDuration:(animated) ? .3f : 0.f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_theNewStoriesButton setX:(shouldDisplay) ? 20.f : -([_theNewStoriesButton getWidth] + 5.f)];
                     } completion:nil];
}

- (void)localContentPurged {
    self.feedFetchedResultsController.delegate = nil;
    self.feedFetchedResultsController = nil;
}

- (void)localContentRestored {
    if (_feedFetchedResultsController) return;

    [self.feedPosts removeAllObjects];

    [self setupFeedFetchRequest];
    [self populateContent];
}

- (void)displayPublishedPost:(NSNotification *)notification {
    if ([notification object]) {
        MRSLPost *post = [notification object];
        [_feedIDs insertObject:post.postID
                       atIndex:0];
        [self.feedCollectionView reloadData];
    }
    [self.feedCollectionView scrollRectToVisible:CGRectMake(2.f, 2.f, 2.f, 2.f)
                                        animated:NO];
}

#pragma mark - Action Methods

- (IBAction)displayNewStories:(id)sender {
    if (_theNewStoriesAvailable) {
        _theNewStoriesAvailable = NO;
        [self toggleNewStoriesButton:NO
                            animated:YES];
        [self.feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_theNewStoriesCount - 1 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
    }
}

#pragma mark - Private Methods

- (void)setupFeedTimer {
    if (!_timer) {
        self.timer = [NSTimer timerWithTimeInterval:180.f
                                             target:self
                                           selector:@selector(loadNew)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer
                                     forMode:NSRunLoopCommonModes];
    }
}

- (void)setupFeedFetchRequest {
    if (_feedFetchedResultsController) return;
    self.feedFetchedResultsController = [MRSLPost MR_fetchAllSortedBy:@"creationDate"
                                                            ascending:NO
                                                        withPredicate:nil
                                                              groupBy:nil
                                                             delegate:self];
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
    if ([_feedIDs count] == 0) {
        [self.activityIndicatorView startAnimating];
    }
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
                                           andCount:@(4)
                                            success:^(NSArray *responseArray) {
                                                [self.activityIndicatorView stopAnimating];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [_feedIDs removeAllObjects];
                                                    [_feedIDs addObjectsFromArray:responseArray];
                                                    [_feedIDs saveFeedIDArray];
                                                    [self populateContent];
                                                });
                                            } failure:^(NSError *error) {
                                                [UIAlertView showAlertViewForErrorString:@"Error loading feed"
                                                                                delegate:nil];
                                            }];
}

- (void)loadNew {
    DDLogDebug(@"Loading new feed items");
    MRSLPost *firstPost = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                 withValue:[_feedIDs firstObject]];
    [_appDelegate.morselApiService getFeedWithMaxID:nil
                                          orSinceID:firstPost.feedItemID
                                           andCount:@(5)
                                            success:^(NSArray *responseArray) {
                                                DDLogDebug(@"%lu feed items added", (unsigned long)[responseArray count]);
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if ([responseArray count] > 0) {
                                                        NSArray *appendedIDs = [_feedIDs copy];
                                                        self.feedIDs = [NSMutableArray arrayWithArray:responseArray];
                                                        [_feedIDs addObjectsFromArray:appendedIDs];
                                                        [_feedIDs saveFeedIDArray];
                                                        NSIndexPath *currentDisplayedMorsel = [[_feedCollectionView indexPathsForVisibleItems] firstObject];
                                                        [self populateContent];
                                                        if ([responseArray count] > 0) {
                                                            DDLogDebug(@"Nuclear Launch detected!");
                                                            self.theNewStoriesCount = (_theNewStoriesAvailable) ? _theNewStoriesCount + [responseArray count] : [responseArray count];
                                                            self.theNewStoriesAvailable = YES;
                                                            [_theNewStoriesButton setTitle:[NSString stringWithFormat:@"%li New Stories", (long)_theNewStoriesCount]
                                                                                  forState:UIControlStateNormal];
                                                            [self toggleNewStoriesButton:YES
                                                                                animated:YES];
                                                            if (currentDisplayedMorsel) {
                                                                [_feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentDisplayedMorsel.row + [responseArray count] inSection:0]
                                                                                            atScrollPosition:UICollectionViewScrollPositionNone
                                                                                                    animated:NO];
                                                            }
                                                        }
                                                    }
                                                });
                                            } failure:^(NSError *error) {
                                                [UIAlertView showAlertViewForErrorString:@"Error loading feed"
                                                                                delegate:nil];
                                            }];
}

- (void)loadMore {
    DDLogDebug(@"Loading more feed items");
    MRSLPost *lastPost = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                 withValue:[_feedIDs lastObject]];
    [_appDelegate.morselApiService getFeedWithMaxID:@([lastPost feedItemIDValue] - 1)
                                          orSinceID:nil
                                           andCount:@(5)
                                            success:^(NSArray *responseArray) {
                                                DDLogDebug(@"%lu feed items added", (unsigned long)[responseArray count]);
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if ([responseArray count] > 0) {
                                                        [_feedIDs addObjectsFromArray:responseArray];
                                                        [_feedIDs saveFeedIDArray];
                                                        [self populateContent];
                                                    }
                                                    _loadingMore = NO;
                                                });
                                            } failure:^(NSError *error) {
                                                [UIAlertView showAlertViewForErrorString:@"Error loading feed"
                                                                                delegate:nil];
                                                _loadingMore = NO;
                                            }];
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
    postPanelCell.delegate = self;
    return postPanelCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (currentPage >= [_feedPosts count] - 3 && !_loadingMore) {
        _loadingMore = YES;
        [self loadMore];
    }
    [self toggleNewStoriesButton:_theNewStoriesAvailable
                        animated:_theNewStoriesAvailable];
    if (_theNewStoriesCount > 0) {
        if (currentPage <= _theNewStoriesCount - 1) {
            self.theNewStoriesAvailable = NO;
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - MRSLFeedPanelCollectionViewCellDelegate

- (void)feedPanelCollectionViewCellDidSelectPreviousStory {
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath.row != 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1
                                                            inSection:0];
        [self.feedCollectionView scrollToItemAtIndexPath:previousIndexPath
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
    }
}

- (void)feedPanelCollectionViewCellDidSelectNextStory {
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath.row + 1 < [_feedPosts count]) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                        inSection:0];
        [self.feedCollectionView scrollToItemAtIndexPath:nextIndexPath
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
    }
}

#pragma mark - Destruction

- (void)dealloc {
    [_timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
