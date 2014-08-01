//
//  MRSLProfileMorselsViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserMorselsFeedViewController.h"

#import <SDWebImage/SDWebImageManager.h>

#import "MRSLAPIService+Morsel.h"
#import "NSMutableArray+Additions.h"

#import "MRSLFeedPanelViewController.h"
#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLMediaManager.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselEditViewController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLUserMorselsFeedViewController ()
<NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
MRSLFeedPanelCollectionViewCellDelegate>

@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (nonatomic) CGFloat previousContentOffset;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *morsels;
@property (strong, nonatomic) NSMutableArray *morselIDs;

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLUserMorselsFeedViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"%@'s morsels", _user.username];

    self.morselIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_morselIDs", _user.username]] ?: [NSMutableArray array];
    if (_morsel) [self.morselIDs addObject:_morsel.morselID];

    self.morsels = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideControls)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControls)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![MRSLUser currentUser] || _feedFetchedResultsController) return;

    [self setupFetchRequest];
    [self populateContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    _feedFetchedResultsController.delegate = nil;
    _feedFetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Notification Methods

- (void)hideControls {
    [self toggleControls:NO];
}

- (void)showControls {
    [self toggleControls:YES];
}

- (void)toggleControls:(BOOL)shouldDisplay {
    _feedCollectionView.scrollEnabled = shouldDisplay;
}


#pragma mark - Action Methods

- (IBAction)displayMorselShare {
    NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLFeedPanelCollectionViewCell *visibleFeedPanel = (MRSLFeedPanelCollectionViewCell *)[self.feedCollectionView cellForItemAtIndexPath:indexPath];
        [visibleFeedPanel.feedPanelViewController displayShare];
    }
}

#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.feedFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                              ascending:NO
                                                          withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", _morselIDs]
                                                                groupBy:nil
                                                               delegate:self];
    _feedFetchedResultsController.delegate = self;
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_feedFetchedResultsController performFetch:&fetchError];
    self.morsels = [[_feedFetchedResultsController fetchedObjects] mutableCopy];
    if ([_morsels count] > 0) {
        [_morsels sortUsingComparator:^NSComparisonResult(MRSLMorsel *morsel1, MRSLMorsel *morsel2) {
            return [@([_morselIDs indexOfObject:morsel1.morselID]) compare:@([_morselIDs indexOfObject:morsel2.morselID])];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_feedCollectionView reloadData];
            if (_morsel && [_morsels containsObject:_morsel]) {
                [_feedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[_morsels indexOfObject:_morsel]
                                                                                inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionNone
                                                    animated:NO];
                self.morsel = nil;
            }
        });
    }
}

#pragma mark - Section Methods

- (void)loadMore {
    if (_loadingMore || !_user || _loadedAll) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more user morsels");
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:[_morselIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getMorselsForUser:_user
                                     withMaxID:@([lastMorsel morselIDValue] - 1)
                                     orSinceID:nil
                                      andCount:@(4)
                                    onlyDrafts:NO
                                       success:^(NSArray *responseArray) {
                                           if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                           DDLogDebug(@"%lu user morsels added", (unsigned long)[responseArray count]);
                                           if (weakSelf) {
                                               if ([responseArray count] > 0) {
                                                   [weakSelf.morselIDs addObjectsFromArray:responseArray];
                                                   [[NSUserDefaults standardUserDefaults] setObject:weakSelf.morselIDs
                                                                                             forKey:[NSString stringWithFormat:@"%@_morselIDs", _user.username]];
                                                   [weakSelf setupFetchRequest];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [weakSelf populateContent];
                                                   });
                                               }
                                               weakSelf.loadingMore = NO;
                                           }
                                       } failure:^(NSError *error) {
                                           if (weakSelf) weakSelf.loadingMore = NO;
                                           [[MRSLEventManager sharedManager] track:@"Error Loading Feed"
                                                                        properties:@{@"view": @"user_feed",
                                                                                     @"message" : NSNullIfNil(error.description),
                                                                                     @"action" : @"load_more"}];
                                       }];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_morsels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    MRSLFeedPanelCollectionViewCell *morselPanelCell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDFeedPanelCellKey
                                                                                                 forIndexPath:indexPath];
    [morselPanelCell setOwningViewController:self
                                  withMorsel:morsel];
    NSMutableIndexSet *morselIndices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, MIN(indexPath.row + 3, ([_morsels count] - 1) - indexPath.row))];
    [[MRSLMediaManager sharedManager] queueCoverMediaForMorsels:[_morsels objectsAtIndexes:morselIndices]];
    morselPanelCell.delegate = self;
    return morselPanelCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320.f, [UIDevice has35InchScreen] ? 416.f : 504.f);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (currentPage >= [_morsels count] - 2) {
        [self loadMore];
    }
    if (_previousContentOffset > scrollView.contentOffset.x) {
        self.scrollDirection = MRSLScrollDirectionRight;
    } else if (_previousContentOffset < scrollView.contentOffset.x) {
        self.scrollDirection = MRSLScrollDirectionLeft;
    }
    self.previousContentOffset = scrollView.contentOffset.x;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"User feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
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
    if (indexPath.row + 1 < [_morsels count]) {
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
    self.feedCollectionView.delegate = nil;
    self.feedCollectionView.dataSource = nil;
    [self.feedCollectionView removeFromSuperview];
    self.feedCollectionView = nil;
}

@end
