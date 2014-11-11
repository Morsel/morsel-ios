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
#import "MRSLAPIService+Like.h"
#import "NSMutableArray+Additions.h"
#import "UIButton+Additions.h"

#import "MRSLCollectionView.h"
#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLMediaManager.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLFeedPanelViewController.h"
#import "MRSLTitleItemView.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedViewController ()
<NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
MRSLFeedPanelCollectionViewCellDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;
@property (nonatomic) BOOL theNewMorselsAvailable;

@property (nonatomic) CGFloat originalFeedWidth;
@property (nonatomic) CGFloat previousContentOffset;
@property (nonatomic) NSInteger theNewMorselsCount;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (weak, nonatomic) IBOutlet UIButton *theNewMorselsButton;
@property (weak, nonatomic) IBOutlet MRSLCollectionView *feedCollectionView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *feedMorsels;
@property (strong, nonatomic) NSMutableArray *morselIDs;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIBarButtonItem *likeBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *space;
@property (strong, nonatomic) UIBarButtonItem *shareBarButtonItem;

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLFeedViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"feed";

    NSInteger recentlyPublishedInteger = [[NSUserDefaults standardUserDefaults] integerForKey:@"recentlyPublishedMorselID"];
    if (recentlyPublishedInteger > 0) self.recentlyPublishedMorselID = @([[NSUserDefaults standardUserDefaults] integerForKey:@"recentlyPublishedMorselID"]);

    self.feedCollectionView.accessibilityLabel = @"Feed";
    [self.feedCollectionView setScrollsToTop:NO];

    self.feedMorsels = [NSMutableArray array];
    self.morselIDs = [NSMutableArray feedIDArray];

    [self resumeTimer];
    [self toggleNewMorselsButton:NO
                        animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableFeedScroll)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableFeedScroll)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addPublishedMorsel:)
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

    //  Don't want the default empty string to show up in between states
    [self.feedCollectionView setEmptyStateTitle:@""];

    MRSLTitleItemView *titleItemView = [[MRSLTitleItemView alloc] init];
    titleItemView.title = nil;
    [self.navigationController.navigationBar.topItem setTitleView:titleItemView];

    [self setupFeedNavigationItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.originalFeedWidth = [UIScreen mainScreen].bounds.size.width;
    if (![MRSLUser currentUser]) return;
    [self resumeTimer];
    if (_feedFetchedResultsController) self.feedFetchedResultsController.delegate = self;
    if (!_feedFetchedResultsController && !_recentlyPublishedMorselID) {
        [self setupFetchRequest];
        [self populateContent];
        [self refreshContent];
        [self resetCollectionViewWidth];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.recentlyPublishedMorselID) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self displayPublishedMorsel];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.feedFetchedResultsController.delegate = nil;
    [self suspendTimer];
}

#pragma mark - Notification Methods

- (void)disableFeedScroll {
    self.feedCollectionView.scrollEnabled = NO;
}

- (void)enableFeedScroll {
    self.feedCollectionView.scrollEnabled = YES;
}

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

- (void)addPublishedMorsel:(NSNotification *)notification {
    MRSLMorsel *publishedMorsel = notification.object;
    if (!publishedMorsel) return;
    self.recentlyPublishedMorselID = publishedMorsel.morselID;
    [self displayPublishedMorsel];
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

- (void)displayPublishedMorsel {
    DDLogDebug(@"Published Morsel detected. Setting published Morsel ID and triggering new load.");
    if (_theNewMorselsAvailable) {
        _theNewMorselsAvailable = NO;
        [self toggleNewMorselsButton:NO
                            animated:NO];
    }
    self.morselIDs = [NSMutableArray feedIDArray];
    [_morselIDs insertObject:_recentlyPublishedMorselID
                     atIndex:0];
    [self setupFetchRequest];
    [self populateContent];
    self.loading = NO;
    self.recentlyPublishedMorselID = nil;
    [[NSUserDefaults standardUserDefaults] setInteger:-1
                                               forKey:@"recentlyPublishedMorselID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)displayMorselShare {
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLFeedPanelCollectionViewCell *visibleFeedPanel = (MRSLFeedPanelCollectionViewCell *)[self.feedCollectionView cellForItemAtIndexPath:indexPath];
        [visibleFeedPanel.feedPanelViewController displayShare];
    }
}

- (IBAction)toggleLike {
    if ([MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLMorsel *morsel = [self.feedMorsels objectAtIndex:indexPath.row];

        self.likeBarButtonItem.enabled = NO;
        if (!morsel.managedObjectContext) return;
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Like Icon",
                                                  @"_view": @"feed",
                                                  @"morsel_id": morsel.morselID}];

        [morsel setLikedValue:!morsel.likedValue];
        [self setLikeButtonImageForMorsel:morsel];

        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService likeMorsel:morsel
                               shouldLike:morsel.likedValue
                                  didLike:^(BOOL doesLike) {
                                      if (morsel.likedValue) [MRSLEventManager sharedManager].likes_given++;
                                      weakSelf.likeBarButtonItem.enabled = YES;
                                  } failure: ^(NSError * error) {
                                      weakSelf.likeBarButtonItem.enabled = YES;
                                      [morsel setLikedValue:!morsel.likedValue];
                                      [morsel setLike_countValue:morsel.like_countValue - 1];
                                      [weakSelf setLikeButtonImageForMorsel:morsel];
                                  }];
    }
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel {
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-on" : @"icon-like-off"];
    [self.likeBarButtonItem setImage:likeImage];
    self.likeBarButtonItem.enabled = YES;
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

- (void)setupFeedNavigationItems {
    self.likeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-like-off"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(toggleLike)];
    self.likeBarButtonItem.width = 20.f;

    self.space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                               target:nil
                                                               action:nil];
    self.space.width = -12;

    self.shareBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-share"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(displayMorselShare)];

    NSArray *buttons = @[self.space, self.shareBarButtonItem, self.likeBarButtonItem];

    self.navigationItem.rightBarButtonItems = buttons;
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedCollectionView toggleLoading:loading];
    });
}

- (void)setLoadingMore:(BOOL)loadingMore {
    _loadingMore = loadingMore;

    [self.feedCollectionView.collectionViewLayout invalidateLayout];
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
        if ([_feedMorsels count] > 0) self.loading = NO;
    });
}

#pragma mark - Section Methods

- (void)refreshContent {
    self.loading = YES;
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getFeedWithMaxID:nil
                                    orSinceID:nil
                                     andCount:@(4)
                                      success:^(NSArray *responseArray) {
                                          if (weakSelf) {
                                              if ([responseArray count] > 0) {
                                                  weakSelf.morselIDs = [responseArray mutableCopy];
                                                  [weakSelf.morselIDs saveFeedIDArray];
                                                  [weakSelf setupFetchRequest];
                                                  [weakSelf populateContent];
                                                  MRSLMorsel *firstMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                                      withValue:[weakSelf.morselIDs firstObject]];
                                                  if (firstMorsel) [weakSelf setLikeButtonImageForMorsel:firstMorsel];
                                              }
                                              weakSelf.loading = NO;
                                          }
                                      } failure:^(NSError *error) {
                                          if (weakSelf) {
                                              [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                           properties:@{@"_view": self.mp_eventView,
                                                                                        @"message" : NSNullIfNil(error.description),
                                                                                        @"action" : @"refresh"}];
                                              weakSelf.loading = NO;
                                          }
                                      }];
}

- (void)loadNew {
    if ([_morselIDs count] == 0 || [self isLoading]) return;
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
                                          if (weakSelf) {
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
                                                  weakSelf.loading = NO;
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
                                          }
                                      } failure:^(NSError *error) {
                                          if (weakSelf) {
                                              [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                           properties:@{@"_view": self.mp_eventView,
                                                                                        @"message" : NSNullIfNil(error.description),
                                                                                        @"action" : @"load_new"}];

                                          }
                                      }];
}

- (void)loadMore {
    if (_loadingMore || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more");
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
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [weakSelf setupFetchRequest];
                                                      [weakSelf populateContent];
                                                      weakSelf.loading = NO;
                                                  });
                                              }
                                          }
                                      } failure:^(NSError *error) {
                                          if (weakSelf) weakSelf.loadingMore = NO;
                                          [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                       properties:@{@"_view": self.mp_eventView,
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
    MRSLMorsel *nextMorsel = nil;
    if (indexPath.row + 1 < [_feedMorsels count] - 1) nextMorsel = [_feedMorsels objectAtIndex:indexPath.row + 1];
    NSString *identifier = [NSString stringWithFormat:@"%@_%d", MRSLStoryboardRUIDFeedPanelCellKey, (int)(indexPath.row % 4)];
    MRSLFeedPanelCollectionViewCell *morselPanelCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                 forIndexPath:indexPath];
    [morselPanelCell setOwningViewController:self
                                  withMorsel:morsel
                               andNextMorsel:nextMorsel];
    NSMutableIndexSet *morselIndices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, MIN(indexPath.row + 3, ([_feedMorsels count] - 1) - indexPath.row))];
    [[MRSLMediaManager sharedManager] queueCoverMediaForMorsels:[_feedMorsels objectsAtIndexes:morselIndices]];
    morselPanelCell.delegate = self;
    return morselPanelCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:MRSLStoryboardRUIDFeedLoadingMoreFooterKey
                                                         forIndexPath:indexPath];
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((indexPath.row == [self.feedMorsels count] - 1) ? self.originalFeedWidth + 1.f : self.originalFeedWidth, [collectionView getHeight]);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return _loadingMore ? CGSizeMake(50.f, [collectionView getHeight]) : CGSizeZero;
}

#pragma mark - UIScrollViewDelegate

/*
 Note: The collection view for the feed is initially set with a width of 321 to force the next cell to display. Upon initial scrolling, the width is set to 320 to ensure the page size is calculated properly. This ensures that when the user dragging (or animation) ends, the cell will land on a multiple of 320 (as opposed to 321). The last cell displayed, however, has it's content size adjusted to 321 to avoid a unique case that causes a 1 pixel overflow on the left side.
 */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.feedCollectionView setWidth:self.originalFeedWidth];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.feedCollectionView setWidth:self.originalFeedWidth];
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
        [[MRSLEventManager sharedManager] registerMorsel:visibleMorsel];
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
    [self.feedCollectionView setWidth:self.originalFeedWidth + 1.f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedCollectionView setWidth:self.originalFeedWidth];
    });
    NSIndexPath *indexPath = [[_feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath && indexPath.row < [_feedMorsels count]) {
        MRSLMorsel *visibleMorsel = [_feedMorsels objectAtIndex:indexPath.row];
        [self setLikeButtonImageForMorsel:visibleMorsel];
    }
    if (![self.navigationController.navigationBar.topItem.titleView isKindOfClass:[MRSLTitleItemView class]]) return;
    [(MRSLTitleItemView *)self.navigationController.navigationBar.topItem.titleView setTitle:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"NSFetchedResultsController detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - MRSLFeedPanelCollectionViewCellDelegate

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

- (void)reset {
    [super reset];
    [self.navigationController.navigationBar.topItem setTitleView:nil];
    [self.feedMorsels removeAllObjects];
    self.feedFetchedResultsController = nil;
    self.feedCollectionView.delegate = nil;
    self.feedCollectionView.dataSource = nil;
    [self.feedCollectionView removeFromSuperview];
    self.feedCollectionView = nil;
}

@end
