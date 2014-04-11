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

    [self setupFeedTimer];
    [self toggleNewMorselsButton:NO
                        animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayPublishedMorsel:)
                                                 name:MRSLUserDidPublishMorselNotification
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
        MRSLMorsel *morsel = [notification object];
        [_feedIDs insertObject:morsel.morselID
                       atIndex:0];
        [self.feedCollectionView reloadData];
    }
    [self.feedCollectionView scrollRectToVisible:CGRectMake(2.f, 2.f, 2.f, 2.f)
                                        animated:NO];
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
    self.feedFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
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
    }
    [self.feedCollectionView reloadData];
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
    MRSLMorsel *firstMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                 withValue:[_feedIDs firstObject]];
    [_appDelegate.itemApiService getFeedWithMaxID:nil
                                          orSinceID:firstMorsel.feedItemID
                                           andCount:@(4)
                                            success:^(NSArray *responseArray) {
                                                DDLogDebug(@"%lu feed items added", (unsigned long)[responseArray count]);
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if ([responseArray count] > 0) {
                                                        NSArray *appendedIDs = [_feedIDs copy];
                                                        self.feedIDs = [NSMutableArray arrayWithArray:responseArray];
                                                        [_feedIDs addObjectsFromArray:appendedIDs];
                                                        [_feedIDs saveFeedIDArray];
                                                        NSIndexPath *indexPath = [[_feedCollectionView indexPathsForVisibleItems] firstObject];
                                                        [self populateContent];
                                                        if ([responseArray count] > 0) {
                                                            DDLogDebug(@"Nuclear Launch detected!");
                                                            self.theNewMorselsCount = (_theNewMorselsAvailable) ? _theNewMorselsCount + [responseArray count] : [responseArray count];
                                                            self.theNewMorselsAvailable = YES;
                                                            [_theNewMorselsButton setTitle:[NSString stringWithFormat:@"%li New Morsels", (long)_theNewMorselsCount]
                                                                                  forState:UIControlStateNormal];
                                                            [self toggleNewMorselsButton:YES
                                                                                animated:YES];
                                                            if (indexPath) {
                                                                [_feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:MIN(indexPath.row + [responseArray count], [_feedMorsels count] - 1) inSection:0]
                                                                                            atScrollPosition:UICollectionViewScrollPositionNone
                                                                                                    animated:NO];
                                                            }
                                                        }
                                                    }
                                                });
                                            } failure:nil];
}

- (void)loadMore {
    DDLogDebug(@"Loading more feed items");
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                 withValue:[_feedIDs lastObject]];
    [_appDelegate.itemApiService getFeedWithMaxID:@([lastMorsel feedItemIDValue] - 1)
                                          orSinceID:nil
                                           andCount:@(4)
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
    if (currentPage >= [_feedMorsels count] - 3 && !_loadingMore) {
        _loadingMore = YES;
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
    if (indexPath) {
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

#pragma mark - Destruction

- (void)dealloc {
    [_timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
