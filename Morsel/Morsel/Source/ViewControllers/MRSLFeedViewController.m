//
//  FeedViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLFeedViewController.h"

#import <SDWebImage/SDWebImageManager.h>

#import "MRSLAPIService+Feed.h"
#import "NSMutableArray+Feed.h"

#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLMediaManager.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLFeedPanelViewController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedViewController ()
<NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
MRSLFeedPanelCollectionViewCellDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;
@property (nonatomic) BOOL theNewMorselsAvailable;

@property (nonatomic) CGFloat previousContentOffset;
@property (nonatomic) NSInteger theNewMorselsCount;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (weak, nonatomic) IBOutlet UIButton *theNewMorselsButton;
@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *feedMorsels;
@property (strong, nonatomic) NSMutableArray *morselIDs;
@property (strong, nonatomic) NSMutableArray *viewedMorsels;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLFeedViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.feedCollectionView.accessibilityLabel = @"Feed";
    [self.feedCollectionView setScrollsToTop:NO];

    self.feedMorsels = [NSMutableArray array];
    self.morselIDs = [NSMutableArray feedIDArray];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspendTimer)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTimer)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    [super viewWillAppear:animated];
    [self showMorselTitleView:YES];
    MRSLUser *currentUser = [MRSLUser currentUser];
    if (!currentUser) return;
    [self resumeTimer];
    if (_feedFetchedResultsController) return;
    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
    [self resetCollectionViewWidth];
}

- (void)viewWillDisappear:(BOOL)animated {
    _feedFetchedResultsController.delegate = nil;
    _feedFetchedResultsController = nil;
    [super viewWillDisappear:animated];
    [self suspendTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self showMorselTitleView:NO];
}

#pragma mark - Notification Methods

- (void)suspendTimer {
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
}

- (void)resumeTimer {
    [self suspendTimer];
    if (!_timer) {
        self.timer = [NSTimer timerWithTimeInterval:60.f
                                             target:self
                                           selector:@selector(loadNew)
                                           userInfo:nil
                                            repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer
                                     forMode:NSRunLoopCommonModes];
    }
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
        if (_theNewMorselsAvailable) {
            _theNewMorselsAvailable = NO;
            [self toggleNewMorselsButton:NO
                                animated:NO];
        }
        MRSLMorsel *morsel = [notification object];
        [_morselIDs insertObject:morsel.morselID
                         atIndex:0];
        [self setupFetchRequest];
        [self populateContent];
        [_feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:NO];
    }
}

- (void)removePublishedMorsel:(NSNotification *)notification {
    if ([notification object]) {
        NSNumber *morselID = [notification object];
        NSInteger morselIndex = [_morselIDs indexOfObject:morselID];
        if (morselIndex != NSNotFound) {
            DDLogDebug(@"Deleted Morsel detected and found displayed in Feed. Removing from feed ID array filter.");
            [_morselIDs removeObjectAtIndex:morselIndex];
            [_morselIDs saveFeedIDArray];
        }
    }
}

- (void)displayMorselShare {
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLFeedPanelCollectionViewCell *visibleFeedPanel = (MRSLFeedPanelCollectionViewCell *)[self.feedCollectionView cellForItemAtIndexPath:indexPath];
        [visibleFeedPanel.feedPanelViewController displayShare];
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

- (void)showMorselTitleView:(BOOL)shouldShow {
    if (shouldShow) {
        UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic-identity-nav"]];
        [titleView setY:-4.f];
        [self.navigationController.navigationBar.topItem setTitleView:titleView];
    } else {
        [self.navigationController.navigationBar.topItem setTitleView:nil];
    }
}

- (void)setupFetchRequest {
    self.feedFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"publishedDate"
                                                              ascending:NO
                                                          withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", _morselIDs]
                                                                groupBy:nil
                                                               delegate:self];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_feedFetchedResultsController performFetch:&fetchError];
    if (_feedFetchedResultsController) {
        self.feedMorsels = [[_feedFetchedResultsController fetchedObjects] mutableCopy];
        [_feedMorsels sortUsingComparator:^NSComparisonResult(MRSLMorsel *morsel1, MRSLMorsel *morsel2) {
            return [@([_morselIDs indexOfObject:morsel1.morselID]) compare:@([_morselIDs indexOfObject:morsel2.morselID])];
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.feedCollectionView reloadData];
    });
}

#pragma mark - Section Methods

- (void)refreshContent {
    self.refreshing = YES;
    if ([_morselIDs count] == 0) [self.activityIndicatorView startAnimating];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getFeedWithMaxID:nil
                                    orSinceID:nil
                                     andCount:@(4)
                                      success:^(NSArray *responseArray) {
                                          [weakSelf.activityIndicatorView stopAnimating];
                                          if ([responseArray count] > 0) {
                                              weakSelf.morselIDs = [responseArray mutableCopy];
                                              [weakSelf.morselIDs saveFeedIDArray];
                                              [weakSelf setupFetchRequest];
                                              [weakSelf populateContent];
                                              weakSelf.refreshing = NO;
                                          }
                                      } failure:^(NSError *error) {
                                          [weakSelf.activityIndicatorView stopAnimating];
                                          [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                       properties:@{@"view": @"main_feed",
                                                                                    @"message" : NSNullIfNil(error.description),
                                                                                    @"action" : @"refresh"}];
                                          weakSelf.refreshing = NO;
                                      }];
}

- (void)loadNew {
    if ([_morselIDs count] == 0 || _refreshing) return;
    DDLogDebug(@"Loading new feed items");
    NSNumber *firstValidID = [_morselIDs firstObjectWithValidFeedItemID];
    if (!firstValidID) return;
    MRSLMorsel *firstMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                        withValue:firstValidID];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getFeedWithMaxID:nil
                                    orSinceID:firstMorsel.feedItemID
                                     andCount:@(4)
                                      success:^(NSArray *responseArray) {
                                          NSSet *existingSet = [NSSet setWithArray:weakSelf.morselIDs];
                                          NSMutableSet *potentialNewSet = [NSMutableSet setWithArray:weakSelf.morselIDs];
                                          [potentialNewSet addObjectsFromArray:responseArray];
                                          BOOL newItemsDetected = ![existingSet isEqualToSet:potentialNewSet];
                                          if (newItemsDetected) {
                                              DDLogDebug(@"%lu new feed item(s) detected!", (unsigned long)[responseArray count]);
                                              NSMutableArray *appendedIDs = [NSMutableArray arrayWithArray:weakSelf.morselIDs];
                                              for (NSNumber *morselID in responseArray) {
                                                  NSInteger index = [appendedIDs indexOfObject:morselID];
                                                  if (index != NSNotFound) [appendedIDs removeObjectAtIndex:index];
                                              }
                                              weakSelf.morselIDs = [NSMutableArray arrayWithArray:responseArray];
                                              [weakSelf.morselIDs addObjectsFromArray:appendedIDs];
                                              [weakSelf.morselIDs saveFeedIDArray];

                                              NSIndexPath *indexPath = [[weakSelf.feedCollectionView indexPathsForVisibleItems] firstObject];
                                              MRSLMorsel *visibleMorsel = [weakSelf.feedMorsels objectAtIndex:indexPath.row];
                                              weakSelf.theNewMorselsCount = [potentialNewSet count] - [existingSet count];
                                              weakSelf.theNewMorselsAvailable = YES;

                                              [weakSelf setupFetchRequest];
                                              [weakSelf populateContent];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf toggleNewMorselsButton:YES
                                                                          animated:YES];
                                                  if (visibleMorsel) {
                                                      @try {
                                                          [weakSelf.feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.feedMorsels indexOfObject:visibleMorsel]
                                                                                                                                  inSection:0]
                                                                                              atScrollPosition:UICollectionViewScrollPositionNone
                                                                                                      animated:NO];
                                                      } @catch (NSException *exception) {
                                                          DDLogError(@"Invalid NSIndexPath: %@", exception);
                                                      }
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
    if (_loadingMore || _loadedAll || _refreshing) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more feed items");
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:[_morselIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getFeedWithMaxID:@([lastMorsel feedItemIDValue] - 1)
                                    orSinceID:nil
                                     andCount:@(4)
                                      success:^(NSArray *responseArray) {
                                          if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                          DDLogDebug(@"%lu feed items added", (unsigned long)[responseArray count]);
                                          if (weakSelf) {
                                              weakSelf.loadingMore = NO;
                                              if ([responseArray count] > 0) {
                                                  [weakSelf.morselIDs addObjectsFromArray:responseArray];
                                                  [weakSelf.morselIDs saveFeedIDArray];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [weakSelf setupFetchRequest];
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
    return CGSizeMake((indexPath.row == [self.feedMorsels count] - 1) ? 321.f : 320.f, [UIDevice has35InchScreen] ? 416.f : 504.f);
}

#pragma mark - UIScrollViewDelegate

/*
 Note: The collection view for the feed is initially set with a width of 321 to force the next cell to display. Upon initial scrolling, the width is set to 320 to ensure the page size is calculated properly. This ensures that when the user dragging (or animation) ends, the cell will land on a multiple of 320 (as opposed to 321). The last cell displayed, however, has it's content size adjusted to 321 to avoid a unique case that causes a 1 pixel overflow on the left side.
*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.feedCollectionView setWidth:320.f];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.feedCollectionView setWidth:320.f];
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
    [self resetCollectionViewWidth];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [self resetCollectionViewWidth];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self resetCollectionViewWidth];
}

- (void)resetCollectionViewWidth {
    [self.feedCollectionView setWidth:321.f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedCollectionView setWidth:320.f];
    });
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
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.feedCollectionView.delegate = nil;
    self.feedCollectionView.dataSource = nil;
    [self.feedCollectionView removeFromSuperview];
    self.feedCollectionView = nil;
}

@end
