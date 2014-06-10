//
//  MRSLFeedPanelCollectionViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPanelViewController.h"

#import "MRSLFeedCoverCollectionViewCell.h"
#import "MRSLFeedPageCollectionViewCell.h"
#import "MRSLFeedShareCollectionViewCell.h"
#import "MRSLSocialService.h"
#import "MRSLModalCommentsViewController.h"
#import "MRSLModalDescriptionViewController.h"
#import "MRSLModalLikersViewController.h"
#import "MRSLModalShareViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLProfileImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedPanelViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
MRSLFeedCoverCollectionViewCellDelegate,
MRSLFeedShareCollectionViewCellDelegate>

@property (nonatomic) BOOL isPresentingMorselLayout;
@property (nonatomic) BOOL isDraggingScrollViewUp;

@property (nonatomic) CGFloat previousContentOffset;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation MRSLFeedPanelViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        [self displayContent];
    }
}

#pragma mark - Notification Methods

- (void)updateContent:(NSNotification *)notification {
    if (![self isViewLoaded]) return;
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];

    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if ([managedObject isKindOfClass:[MRSLMorsel class]]) {
            MRSLMorsel *morsel = (MRSLMorsel *)managedObject;
            if (morsel.morselIDValue == weakSelf.morsel.morselIDValue) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf displayContent];
                });
                *stop = YES;
            }
        }
    }];
}

#pragma mark - Private Methods

- (void)displayContent {
    if (_collectionView && _morsel) {
        self.view.backgroundColor = [UIColor whiteColor];

        self.pageControl.numberOfPages = [_morsel.items count] + 2;
        [self.pageControl setY:320.f - ((([_pageControl sizeForNumberOfPages:_pageControl.numberOfPages].width) / 2) + 34.f)];
        self.pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);

        [self.collectionView reloadData];
        [self resetCollectionViewContentOffset:NO];
    }
}

- (void)resetCollectionViewContentOffset:(BOOL)animated {
    [self.collectionView setContentOffset:CGPointMake(0.f, 0.f)
                                 animated:animated];
}

- (MRSLItem *)visibleItem {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    MRSLItem *visibleItem = [_morsel coverItem];
    if (indexPath.row - 1 >= 0 && indexPath.row - 1 < [_morsel.items count]) {
        visibleItem = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
    }
    return visibleItem;
}

#pragma mark - Action Methods

- (IBAction)viewMore {
    MRSLItem *visibleItem = [self visibleItem];
    [[MRSLEventManager sharedManager] track:@"Tapped View More Description"
                                 properties:@{@"view": @"main_feed",
                                              @"item_id": NSNullIfNil(visibleItem.itemID)}];
    MRSLModalDescriptionViewController *modalDescriptionVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalDescriptionViewController"];
    modalDescriptionVC.item = visibleItem;
    [self addChildViewController:modalDescriptionVC];
    [self.view addSubview:modalDescriptionVC.view];
}

- (IBAction)displayComments {
    MRSLItem *visibleItem = [self visibleItem];
    [[MRSLEventManager sharedManager] track:@"Tapped Comments"
                                 properties:@{@"view": @"main_feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(visibleItem.itemID),
                                              @"comment_count": NSNullIfNil(visibleItem.comment_count)}];
    UINavigationController *commentNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_Comments"];
    MRSLModalCommentsViewController *modalCommentsVC = [[commentNC viewControllers] firstObject];
    modalCommentsVC.item = visibleItem;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:commentNC];
}

- (IBAction)displayLikers {
    __block BOOL alreadyDisplayed = NO;
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *childVC, NSUInteger idx, BOOL *stop) {
        if ([childVC isKindOfClass:[MRSLModalLikersViewController class]]) {
            alreadyDisplayed = YES;
            *stop = YES;
        }
    }];
    if (!alreadyDisplayed) {
        MRSLItem *visibleItem = [self visibleItem];
        [[MRSLEventManager sharedManager] track:@"Tapped Likes"
                                     properties:@{@"view": @"main_feed",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(visibleItem.itemID),
                                                  @"like_count": NSNullIfNil(visibleItem.like_count)}];
        UINavigationController *likesNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_Likes"];
        MRSLModalLikersViewController *modalLikersVC = [[likesNC viewControllers] firstObject];
        modalLikersVC.item = visibleItem;
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:likesNC];
    }
}

- (IBAction)displayShare {
    __block BOOL alreadyDisplayed = NO;
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *childVC, NSUInteger idx, BOOL *stop) {
        if ([childVC isKindOfClass:[MRSLModalShareViewController class]]) {
            alreadyDisplayed = YES;
            *stop = YES;
        }
    }];
    if (!alreadyDisplayed) {
        MRSLItem *visibleItem = [self visibleItem];
        [[MRSLEventManager sharedManager] track:@"Tapped Share Morsel"
                                     properties:@{@"view": @"main_feed",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(visibleItem.itemID)}];
        MRSLModalShareViewController *modalShareVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalShareViewController"];
        modalShareVC.item = visibleItem;
        [self addChildViewController:modalShareVC];
        [self.view addSubview:modalShareVC.view];
    }
}


- (IBAction)editMorsel {
    UINavigationController *morselEditNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselEdit"];
    MRSLMorselEditViewController *morselEditVC = [[morselEditNC viewControllers] firstObject];
    morselEditVC.morselID = _morsel.morselID;
    [self presentViewController:morselEditNC
                       animated:YES
                     completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_morsel.items count] + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.row == 0) {
        MRSLFeedCoverCollectionViewCell *morselCoverCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_FeedCoverCell"
                                                                                                     forIndexPath:indexPath];
        morselCoverCell.morsel = _morsel;
        morselCoverCell.delegate = self;
        cell = morselCoverCell;
    } else if (indexPath.row == [_morsel.items count] + 1) {
        MRSLFeedShareCollectionViewCell *shareCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_FeedShareCell"
                                                                                               forIndexPath:indexPath];
        shareCell.morsel = _morsel;
        shareCell.delegate = self;
        cell = shareCell;
    } else {
        MRSLFeedPageCollectionViewCell *morselPageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_FeedPageCell"
                                                                                                   forIndexPath:indexPath];
        morselPageCell.item = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        cell = morselPageCell;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIDeviceScreenSize screenSize = [[UIDevice currentDevice] screenSize];
    return CGSizeMake(320.f, (screenSize == UIDeviceScreenSize35Inch) ? 416.f : 504.f);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentPage = scrollView.contentOffset.y / scrollView.frame.size.height;
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    self.pageControl.currentPage = (translation.y > 0) ? ceilf(currentPage) : floorf(currentPage);
    if (_previousContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = MRSLScrollDirectionDown;
    } else if (_previousContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = MRSLScrollDirectionUp;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [[_collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath && indexPath.row - 1 < [_morsel.items count]) {
        MRSLItem *visibleMorsel = nil;
        if (_isPresentingMorselLayout && indexPath.row != 0) {
            visibleMorsel = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        } else {
            visibleMorsel = [_morsel coverItem];
        }
        CGFloat currentPage = scrollView.contentOffset.y / scrollView.frame.size.height;
        BOOL onShare = (currentPage == [_morsel.items count] + 2);

        if (_scrollDirection == MRSLScrollDirectionDown) {
            [[MRSLEventManager sharedManager] track:@"Scroll Morsel Down"
                                         properties:@{@"view": @"main_feed",
                                                      @"morsel_id": NSNullIfNil(visibleMorsel.morsel.morselID),
                                                      @"item_id": NSNullIfNil(visibleMorsel.itemID),
                                                      @"on_share": (onShare) ? @"true" : @"false",
                                                      @"item_scroll_index": NSNullIfNil(@(currentPage))}];
        } else if (_scrollDirection == MRSLScrollDirectionUp) {
            [[MRSLEventManager sharedManager] track:@"Scroll Morsel Up"
                                         properties:@{@"view": @"main_feed",
                                                      @"morsel_id": NSNullIfNil(visibleMorsel.morsel.morselID),
                                                      @"item_id": NSNullIfNil(visibleMorsel.itemID),
                                                      @"on_share": (onShare) ? @"true" : @"false",
                                                      @"item_scroll_index": NSNullIfNil(@(currentPage))}];
        }
    }
}

#pragma mark - MRSLFeedCoverCollectionViewCellDelegate

- (void)feedCoverCollectionViewCellDidSelectMorsel:(MRSLItem *)item {
    NSInteger itemIndex = [_morsel.itemsArray indexOfObject:item] + 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:itemIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:YES];
}

#pragma mark - MRSLFeedShareCollectionViewCellDelegate

- (void)feedShareCollectionViewCellDidSelectShareFacebook {
    [[MRSLSocialService sharedService] shareMorselToFacebook:_morsel
                                            inViewController:self
                                                     success:nil
                                                      cancel:nil];
}

- (void)feedShareCollectionViewCellDidSelectShareTwitter {
    [[MRSLSocialService sharedService] shareMorselToTwitter:_morsel
                                           inViewController:self
                                                    success:nil
                                                     cancel:nil];
}

- (void)feedShareCollectionViewCellDidSelectPreviousMorsel {
    if ([self.delegate respondsToSelector:@selector(feedPanelViewControllerDidSelectPreviousMorsel)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetCollectionViewContentOffset:YES];
        });
        [self.delegate feedPanelViewControllerDidSelectPreviousMorsel];
    }
}

- (void)feedShareCollectionViewCellDidSelectNextMorsel {
    if ([self.delegate respondsToSelector:@selector(feedPanelViewControllerDidSelectNextMorsel)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetCollectionViewContentOffset:YES];
        });
        [self.delegate feedPanelViewControllerDidSelectNextMorsel];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
