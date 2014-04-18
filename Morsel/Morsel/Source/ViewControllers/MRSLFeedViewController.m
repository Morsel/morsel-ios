//
//  FeedViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLFeedViewController.h"

#import <SDWebImage/SDWebImageManager.h>

#import "NSMutableArray+Feed.h"

#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLMediaManager.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselEditViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedViewController ()
<NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
MRSLFeedPanelCollectionViewCellDelegate>

@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL theNewMorselsAvailable;

@property (nonatomic) CGFloat previousContentOffset;
@property (nonatomic) NSInteger theNewMorselsCount;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (weak, nonatomic) IBOutlet UIButton *menuBarButton;
@property (weak, nonatomic) IBOutlet UIButton *addMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *theNewMorselsButton;
@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *feedMorsels;
@property (strong, nonatomic) NSMutableArray *feedIDs;
@property (strong, nonatomic) NSMutableArray *viewedMorsels;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLFeedViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.feedCollectionView.accessibilityLabel = @"Feed";

    self.feedMorsels = [NSMutableArray array];
    self.feedIDs = [NSMutableArray feedIDArray];
    self.viewedMorsels = [NSMutableArray array];

    [self resumeTimer];
    [self toggleNewMorselsButton:NO
                        animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayPublishedMorsel:)
                                                 name:MRSLUserDidPublishMorselNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removePublishedMorsel:)
                                                 name:MRSLUserDidDeleteMorselNotification
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
    [self resumeTimer];

    if (![MRSLUser currentUser] || _feedFetchedResultsController) return;

    [self setupFeedFetchRequest];
    [self populateContent];
    [self refreshFeed];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self suspendTimer];
}

#pragma mark - Notification Methods

- (void)suspendTimer {
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
}

- (void)resumeTimer {
    if (!_timer) {
        self.timer = [NSTimer timerWithTimeInterval:180.f
                                             target:self
                                           selector:@selector(loadNew)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer
                                     forMode:NSRunLoopCommonModes];
    }
    [self loadNew];
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
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_menuBarButton setAlpha:shouldDisplay];
                         [_addMorselButton setAlpha:shouldDisplay];
                     }];
}

- (void)toggleNewMorselsButton:(BOOL)shouldDisplay
                      animated:(BOOL)animated {
    [UIView animateWithDuration:(animated) ? .3f : 0.f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_theNewMorselsButton setX:(shouldDisplay) ? 20.f : -([_theNewMorselsButton getWidth] + 5.f)];
                     } completion:nil];
}

- (void)displayPublishedMorsel:(NSNotification *)notification {
    if ([notification object]) {
        DDLogDebug(@"Published Morsel detected. Setting published Morsel ID and triggering new load.");
        MRSLMorsel *morsel = [notification object];
        [_feedIDs insertObject:morsel.morselID
                       atIndex:0];
        [_feedCollectionView reloadData];
        [_feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:NO];
    }
}

- (void)removePublishedMorsel:(NSNotification *)notification {
    if ([notification object]) {
        NSNumber *morselID = [notification object];
        NSInteger morselIndex = [_feedIDs indexOfObject:morselID];
        if (morselIndex != NSNotFound) {
            DDLogDebug(@"Deleted Morsel detected and found displayed in Feed. Removing from feed ID array filter.");
            [_feedIDs removeObjectAtIndex:morselIndex];
            [_feedIDs saveFeedIDArray];
        }
    }
}

#pragma mark - Action Methods

- (IBAction)displayNewMorsels:(id)sender {
    if (_theNewMorselsAvailable) {
        _theNewMorselsAvailable = NO;
        [self toggleNewMorselsButton:NO
                            animated:YES];
        [self.feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
    }
}

#pragma mark - Private Methods

- (void)setupFeedFetchRequest {
    if (_feedFetchedResultsController) return;
    self.feedFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"publishedDate"
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
        [self.feedMorsels removeAllObjects];
        NSPredicate *feedIDPredicate = [NSPredicate predicateWithFormat:@"morselID IN %@", _feedIDs];
        [self.feedMorsels addObjectsFromArray:[[_feedFetchedResultsController fetchedObjects] filteredArrayUsingPredicate:feedIDPredicate]];
        [_feedMorsels sortUsingComparator:^NSComparisonResult(MRSLMorsel *morsel1, MRSLMorsel *morsel2) {
            return [@([_feedIDs indexOfObject:morsel1.morselID]) compare:@([_feedIDs indexOfObject:morsel2.morselID])];
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.feedCollectionView reloadData];
    });
}

#pragma mark - Section Methods

- (void)refreshFeed {
    if ([_feedIDs count] == 0) {
        [self.activityIndicatorView startAnimating];
    }
    [_appDelegate.itemApiService getFeedWithMaxID:nil
                                        orSinceID:nil
                                         andCount:@(4)
                                          success:^(NSArray *responseArray) {
                                              [self.activityIndicatorView stopAnimating];
                                              if ([responseArray count] > 0) {
                                                  [_feedIDs removeAllObjects];
                                                  [_feedIDs addObjectsFromArray:responseArray];
                                                  [_feedIDs saveFeedIDArray];
                                                  [self populateContent];
                                              }
                                          } failure:^(NSError *error) {
                                              [self.activityIndicatorView stopAnimating];
                                              [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                           properties:@{@"view": @"main_feed",
                                                                                        @"message" : NSNullIfNil(error.description),
                                                                                        @"action" : @"refresh"}];
                                          }];
}

- (void)loadNew {
    if ([_feedIDs count] == 0) return;
    DDLogDebug(@"Loading new feed items");
    NSNumber *firstValidID = [_feedIDs firstObjectWithValidFeedItemID];
    if (!firstValidID) return;
    MRSLMorsel *firstMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                        withValue:firstValidID];
    [_appDelegate.itemApiService getFeedWithMaxID:nil
                                        orSinceID:firstMorsel.feedItemID
                                         andCount:@(4)
                                          success:^(NSArray *responseArray) {
                                              NSSet *existingSet = [NSSet setWithArray:_feedIDs];
                                              NSMutableSet *potentialNewSet = [NSMutableSet setWithArray:_feedIDs];
                                              [potentialNewSet addObjectsFromArray:responseArray];
                                              BOOL newItemsDetected = ![existingSet isEqualToSet:potentialNewSet];
                                              if (newItemsDetected) {
                                                  DDLogDebug(@"%lu new feed item(s) detected!", (unsigned long)[responseArray count]);
                                                  NSArray *appendedIDs = [_feedIDs copy];
                                                  self.feedIDs = [NSMutableArray arrayWithArray:responseArray];
                                                  [_feedIDs addObjectsFromArray:appendedIDs];
                                                  [_feedIDs saveFeedIDArray];

                                                  NSIndexPath *indexPath = [[_feedCollectionView indexPathsForVisibleItems] firstObject];
                                                  MRSLMorsel *visibleMorsel = [_feedMorsels objectAtIndex:indexPath.row];
                                                  self.theNewMorselsCount = [potentialNewSet count] - [existingSet count];
                                                  self.theNewMorselsAvailable = YES;

                                                  [self populateContent];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [_theNewMorselsButton setTitle:[NSString stringWithFormat:@"%li New Morsel%@", (long)_theNewMorselsCount, (_theNewMorselsCount == 1) ? @"" : @"s"]
                                                                            forState:UIControlStateNormal];
                                                      [self toggleNewMorselsButton:YES
                                                                          animated:YES];
                                                      if (visibleMorsel) {
                                                          [_feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[_feedMorsels indexOfObject:visibleMorsel]
                                                                                                                          inSection:0]
                                                                                      atScrollPosition:UICollectionViewScrollPositionNone
                                                                                              animated:NO];
                                                      }
                                                  });
                                              } else {
                                                  DDLogDebug(@"No new feed items detected");
                                              }
                                          } failure:^(NSError *error) {
                                              [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                           properties:@{@"view": @"main_feed",
                                                                                        @"message" : NSNullIfNil(error.description),
                                                                                        @"action" : @"load_new"}];
                                          }];
}

- (void)loadMore {
    if (_loadingMore) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more feed items");
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:[_feedIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.itemApiService getFeedWithMaxID:@([lastMorsel feedItemIDValue] - 1)
                                        orSinceID:nil
                                         andCount:@(4)
                                          success:^(NSArray *responseArray) {
                                              DDLogDebug(@"%lu feed items added", (unsigned long)[responseArray count]);
                                              if (weakSelf) {
                                                  weakSelf.loadingMore = NO;
                                                  if ([responseArray count] > 0) {
                                                      [weakSelf.feedIDs addObjectsFromArray:responseArray];
                                                      [weakSelf.feedIDs saveFeedIDArray];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [weakSelf populateContent];
                                                      });
                                                  }
                                              }
                                          } failure:^(NSError *error) {
                                              if (weakSelf) weakSelf.loadingMore = NO;
                                              [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                           properties:@{@"view": @"main_feed",
                                                                                        @"message" : NSNullIfNil(error.description),
                                                                                        @"action" : @"load_more"}];
                                          }];
}

- (void)displayUserProfile {
    [[MRSLEventManager sharedManager] track:@"Tapped Profile Icon"
                                 properties:@{@"view": @"main_feed",
                                              @"user_id": _currentUser.userID}];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_ProfileViewController"];
    profileVC.user = _currentUser;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_feedMorsels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_feedMorsels objectAtIndex:indexPath.row];
    MRSLFeedPanelCollectionViewCell *morselPanelCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_FeedPanelCell"
                                                                                                 forIndexPath:indexPath];
    [morselPanelCell setOwningViewController:self
                                  withMorsel:morsel];
    NSMutableIndexSet *morselIndices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, MIN(indexPath.row + 3, ([_feedMorsels count] - 1) - indexPath.row))];
    [[MRSLMediaManager sharedManager] queueCoverMediaForMorsels:[_feedMorsels objectsAtIndexes:morselIndices]];
    morselPanelCell.delegate = self;
    return morselPanelCell;
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
    if ((currentPage >= [_feedMorsels count] - 3 && !_loadingMore) || (currentPage == [_feedMorsels count] - 1)) {
        [self loadMore];
    }
    if (_previousContentOffset > scrollView.contentOffset.x) {
        self.scrollDirection = MRSLScrollDirectionRight;
    } else if (_previousContentOffset < scrollView.contentOffset.x) {
        self.scrollDirection = MRSLScrollDirectionLeft;
    }
    self.previousContentOffset = scrollView.contentOffset.x;

    [self toggleNewMorselsButton:_theNewMorselsAvailable
                        animated:_theNewMorselsAvailable];
    if (_theNewMorselsCount > 0) {
        if (currentPage <= _theNewMorselsCount - 1) {
            self.theNewMorselsAvailable = NO;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [[_feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath && indexPath.row < [_feedMorsels count]) {
        MRSLMorsel *visibleMorsel = [_feedMorsels objectAtIndex:indexPath.row];
        BOOL isLast = ([_feedMorsels indexOfObject:visibleMorsel] == [_feedMorsels count] - 1);
        NSNumber *morselID = @(visibleMorsel.morselIDValue);
        BOOL morselIDFound = CFArrayContainsValue ((__bridge CFArrayRef)_viewedMorsels,
                                                   CFRangeMake(0, _viewedMorsels.count),
                                                   (CFNumberRef)morselID );
        if (!morselIDFound) [_viewedMorsels addObject:morselID];
        if (_scrollDirection == MRSLScrollDirectionRight) {
            [[MRSLEventManager sharedManager] track:@"Scroll Feed Right"
                                         properties:@{@"view": @"main_feed",
                                                      @"morsel_id": NSNullIfNil(visibleMorsel.morselID),
                                                      @"is_last": (isLast) ? @"true" : @"false",
                                                      @"morsels_viewed": NSNullIfNil(@([_viewedMorsels count]))}];
        } else if (_scrollDirection == MRSLScrollDirectionLeft) {
            [[MRSLEventManager sharedManager] track:@"Scroll Feed Left"
                                         properties:@{@"view": @"main_feed",
                                                      @"morsel_id": NSNullIfNil(visibleMorsel.morselID),
                                                      @"is_last": (isLast) ? @"true" : @"false",
                                                      @"morsels_viewed": NSNullIfNil(@([_viewedMorsels count]))}];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - MRSLFeedPanelCollectionViewCellDelegate

- (void)feedPanelCollectionViewCellDidSelectPreviousMorsel {
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath.row != 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1
                                                            inSection:0];
        [self.feedCollectionView scrollToItemAtIndexPath:previousIndexPath
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
    }
}

- (void)feedPanelCollectionViewCellDidSelectNextMorsel {
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath.row + 1 < [_feedMorsels count]) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                        inSection:0];
        [self.feedCollectionView scrollToItemAtIndexPath:nextIndexPath
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:YES];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [_timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
