//
//  MRSLProfileMorselsViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselDetailViewController.h"

#import <SDWebImage/SDWebImageManager.h>

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Like.h"
#import "NSMutableArray+Additions.h"

#import "MRSLFeedPanelViewController.h"
#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLMediaManager.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLMorselTaggedUsersViewController.h"
#import "MRSLModalLikersViewController.h"
#import "MRSLModalCommentsViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselDetailViewController ()
<NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
MRSLFeedPanelCollectionViewCellDelegate>

@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;
@property (nonatomic) BOOL isPreview;
@property (nonatomic) BOOL queuedToDisplayTaggedUsers;
@property (nonatomic) BOOL queuedToDisplayLikers;
@property (nonatomic) BOOL queuedToDisplayComments;

@property (nonatomic) NSNumber *queuedItemID;

@property (nonatomic) CGFloat previousContentOffset;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;

@property (strong, nonatomic) NSFetchedResultsController *feedFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *morsels;
@property (strong, nonatomic) NSMutableArray *morselIDs;
@property (strong, nonatomic) UIBarButtonItem *likeBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *space;
@property (strong, nonatomic) UIBarButtonItem *shareBarButtonItem;

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLMorselDetailViewController

#pragma mark - Instance Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    self.userInfo = userInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.userInfo[@"morsel_id"]) {
        self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                withValue:self.userInfo[@"morsel_id"]];
        if (!_morsel) {
            self.morsel = [MRSLMorsel MR_createEntity];
            self.morsel.morselID = @([self.userInfo[@"morsel_id"] intValue]);
        } else {
            self.user = self.morsel.creator;
        }
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService getMorsel:_morsel
                                  orWithID:nil
                                   success:^(id responseObject) {
                                       if (weakSelf) {
                                           if ([responseObject isKindOfClass:[MRSLMorsel class]]) weakSelf.morsel = responseObject;
                                           [weakSelf setupFetchRequest];
                                           [weakSelf populateContent];
                                       }
                                   } failure:^(NSError *error) {
                                       [UIAlertView showAlertViewForErrorString:@"Unable to load morsel."
                                                                       delegate:nil];
                                   }];
        if ([self.userInfo[@"action"] isEqualToString:@"user_tags"]) {
            self.queuedToDisplayTaggedUsers = YES;
        } else if ([self.userInfo[@"action"] isEqualToString:@"likers"]) {
            self.queuedToDisplayLikers = YES;
        } else if ([self.userInfo[@"action"] isEqualToString:@"comments"]) {
            self.queuedItemID = self.userInfo[@"item_id"];
            self.queuedToDisplayComments = (self.queuedItemID != nil);
        }
    }

    self.mp_eventView = @"morsel_detail";

    self.isPreview = (_morsel.publishedDate == nil);

    if (_isExplore || _isPreview) self.feedCollectionView.alwaysBounceHorizontal = NO;
    if (_isPreview) self.navigationItem.rightBarButtonItem = nil;
    self.morselIDs = (!_isPreview && !_isExplore) ? ([[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_morselIDs", _user.username]] ?: [NSMutableArray array]) : [NSMutableArray array];

    self.morsels = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideControls)
                                                 name:MRSLModalWillDisplayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControls)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
    if (!_isPreview) [self setupFeedNavigationItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![MRSLUser currentUser] || _feedFetchedResultsController || (!_morsel && !_user)) return;

    [self setupFetchRequest];
    [self populateContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                   withValue:self.userInfo[@"morsel_id"]];
    if (self.queuedToDisplayTaggedUsers) {
        self.queuedToDisplayTaggedUsers = NO;
        if (morsel) {
            UINavigationController *taggedNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardTaggedUsersKey];
            MRSLMorselTaggedUsersViewController *taggedUsersVC = [[taggedNC viewControllers] firstObject];
            taggedUsersVC.morsel = morsel;
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                                object:taggedNC];
        }
    } else if (self.queuedToDisplayLikers) {
        self.queuedToDisplayLikers = NO;
        if (morsel) {
            UINavigationController *likesNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardLikesKey];
            MRSLModalLikersViewController *modalLikersVC = [[likesNC viewControllers] firstObject];
            modalLikersVC.morsel = morsel;
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                                object:likesNC];
        }
    } else if (self.queuedToDisplayComments) {
        self.queuedToDisplayComments = NO;
        MRSLItem *morselItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                       withValue:self.queuedItemID];
        if (morselItem) {
            UINavigationController *commentNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCommentsKey];
            MRSLModalCommentsViewController *modalCommentsVC = [[commentNC viewControllers] firstObject];
            modalCommentsVC.item = morselItem;
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                                object:commentNC];
            NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
            if (indexPath) {
                MRSLFeedPanelCollectionViewCell *visibleFeedPanel = (MRSLFeedPanelCollectionViewCell *)[self.feedCollectionView cellForItemAtIndexPath:indexPath];
                [visibleFeedPanel.feedPanelViewController scrollToMorselItem:morselItem];
            }
        }
    }
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
        MRSLMorsel *morsel = [self.morsels objectAtIndex:indexPath.row];

        self.likeBarButtonItem.enabled = NO;
        if (!morsel.managedObjectContext) return;
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Like Icon",
                                                  @"_view": self.mp_eventView,
                                                  @"morsel_id": morsel.morselID}];

        [morsel setLikedValue:!morsel.likedValue];
        [self setLikeButtonImageForMorsel:morsel];

        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService likeItem:nil
                             orLikeMorsel:morsel
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

- (void)setupFetchRequest {
    self.feedFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                              ascending:NO
                                                          withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", _morselIDs]
                                                                groupBy:nil
                                                               delegate:self];
    _feedFetchedResultsController.delegate = self;
}

- (void)populateContent {
    if (_morsel && ![self.morselIDs containsObject:_morsel.morselID]) {
        [self.morselIDs addObject:_morsel.morselID];
        self.user = self.morsel.creator;
    }
    if (_isPreview) {
        self.title = @"Preview";
    } else if (_isExplore) {
        if (!self.morsel) {
            NSIndexPath *indexPath = [[self.feedCollectionView indexPathsForVisibleItems] firstObject];
            if (indexPath) {
                MRSLMorsel *morsel = [self.morsels objectAtIndex:indexPath.row];
                self.title = morsel.title;
            }
        } else {
            self.title = self.morsel.title;
        }
    } else {
        self.title = [NSString stringWithFormat:@"%@", _user.username];
    }
    if (self.morsel) [self setLikeButtonImageForMorsel:self.morsel];
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
    if (_loadingMore || !_user || _loadedAll || _isPreview || _isExplore) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more");
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
                                                                        properties:@{@"_view": self.mp_eventView,
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
    NSString *identifier = [NSString stringWithFormat:@"%@_%d", MRSLStoryboardRUIDFeedPanelCellKey, (int)(indexPath.row % 4)];
    MRSLFeedPanelCollectionViewCell *morselPanelCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                 forIndexPath:indexPath];
    [morselPanelCell setOwningViewController:self
                                  withMorsel:morsel
                               andNextMorsel:nil];
    NSMutableIndexSet *morselIndices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, MIN(indexPath.row + 3, ([_morsels count] - 1) - indexPath.row))];
    [[MRSLMediaManager sharedManager] queueCoverMediaForMorsels:[_morsels objectsAtIndexes:morselIndices]];
    morselPanelCell.delegate = self;
    return morselPanelCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([collectionView getWidth], [collectionView getHeight]);
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self handleScrollComplete];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self handleScrollComplete];
}

- (void)handleScrollComplete {
    NSIndexPath *indexPath = [[_feedCollectionView indexPathsForVisibleItems] firstObject];
    if (indexPath && indexPath.row < [_morsels count]) {
        MRSLMorsel *visibleMorsel = [_morsels objectAtIndex:indexPath.row];
        [self setLikeButtonImageForMorsel:visibleMorsel];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"User feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - MRSLFeedPanelCollectionViewCellDelegate

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

@end
