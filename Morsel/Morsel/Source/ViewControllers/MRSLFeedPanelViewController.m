//
//  MRSLFeedPanelCollectionViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPanelViewController.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

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

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation MRSLFeedPanelViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideContent)
                                                                     name:MRSLModalWillDisplayNotification
                                                                   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContent)
                                                 name:MRSLModalWillDismissNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    [self.morselTitleLabel addStandardShadow];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        [self displayContent];
    }
}

#pragma mark - Notification Methods

- (void)hideContent {
    [self toggleContent:NO];
}

- (void)showContent {
    [self toggleContent:YES];
}

- (void)updateContent:(NSNotification *)notification {
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

        self.profileImageView.user = _morsel.creator;

        self.userNameLabel.text = _morsel.creator.fullName;
        self.userNameLabel.textColor = [UIColor morselDarkContent];

        self.pageControl.alpha = 0.f;
        self.pageControl.numberOfPages = [_morsel.items count];
        self.pageControl.hidden = !([_morsel.items count] > 1);
        [self.pageControl setY:[self.view getHeight] - ((([_pageControl sizeForNumberOfPages:_pageControl.numberOfPages].width) / 2) + 34.f)];
        self.pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);

        self.morselTitleLabel.text = _morsel.title;
        [self.morselTitleLabel setX:30.f];
        [self.morselTitleLabel setY:86.f];
        [self.morselTitleLabel setHeight:140.f];
        [self.morselTitleLabel setWidth:260.f];
        [self.morselTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:32.f]];

        self.timeSinceLabel.text = [_morsel.publishedDate timeAgo];

        [self.collectionView reloadData];
        [self resetCollectionViewContentOffset:NO];

        CGFloat currentPage = _collectionView.contentOffset.y / _collectionView.frame.size.height;
        [self determineLayoutForPage:currentPage];
    }
}

- (void)toggleContent:(BOOL)shouldDisplay {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_morselTitleLabel setAlpha:shouldDisplay];
                         [_profileImageView setAlpha:shouldDisplay];
                         [_userNameLabel setAlpha:shouldDisplay];
                         [_timeSinceLabel setAlpha:shouldDisplay];
                     }];
}

- (void)resetCollectionViewContentOffset:(BOOL)animated {
    [self.collectionView setContentOffset:CGPointMake(0.f, 0.f)
                                 animated:animated];
}

- (void)setupCoverLayout {
    self.profileImageView.hidden = NO;
    self.userNameLabel.hidden = NO;
    self.timeSinceLabel.hidden = NO;

    if (_isPresentingMorselLayout) {
        self.isPresentingMorselLayout = NO;
    } else {
        return;
    }

    [self.morselTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:32.f]];
    [self.morselTitleLabel setHeight:140.f];
    [self.morselTitleLabel setWidth:260.f];

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.userNameLabel setTextColor:[UIColor morselDarkContent]];
                         [self.morselTitleLabel setX:30.f];
                         [self.morselTitleLabel setY:(![UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) ? 66.f : 86.f];
                         [self.pageControl setAlpha:0.f];
                     }];
    [self.view.layer removeAnimationForKey:@"fadeToBlackAnimation"];
    CABasicAnimation *fadeToBlack = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    fadeToBlack.fromValue = (id)[UIColor blackColor].CGColor;
    fadeToBlack.toValue = (id)[UIColor whiteColor].CGColor;
    [fadeToBlack setDuration:.3f];
    [self.view.layer addAnimation:fadeToBlack
                           forKey:@"fadeToWhiteAnimation"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)setupMorselLayout {
    if (!_isPresentingMorselLayout) {
        self.isPresentingMorselLayout = YES;
    } else {
        return;
    }

    self.profileImageView.hidden = NO;
    self.userNameLabel.hidden = NO;
    self.timeSinceLabel.hidden = NO;

    [self.morselTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:17.f]];
    CGSize morselTitleLabelSize = [self.morselTitleLabel.text sizeWithFont:_morselTitleLabel.font constrainedToSize:CGSizeMake(212.f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    [self.morselTitleLabel setHeight:morselTitleLabelSize.height];
    [self.morselTitleLabel setWidth:212.f];

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.userNameLabel setTextColor:[UIColor morselLightOffColor]];
                         [self.morselTitleLabel setX:54.f];
                         [self.morselTitleLabel setY:(![UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) ? 8.f : 28.f];
                         [self.pageControl setAlpha:1.f];
                     }];
    [self.view.layer removeAnimationForKey:@"fadeToWhiteAnimation"];
    CABasicAnimation *fadeToBlack = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    fadeToBlack.fromValue = (id)[UIColor whiteColor].CGColor;
    fadeToBlack.toValue = (id)[UIColor blackColor].CGColor;
    [fadeToBlack setDuration:.3f];
    [self.view.layer addAnimation:fadeToBlack
                           forKey:@"fadeToBlackAnimation"];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)setupShareLayout {
    [self setupCoverLayout];
    self.profileImageView.hidden = YES;
    self.userNameLabel.hidden = YES;
    self.timeSinceLabel.hidden = YES;
}

- (void)determineLayoutForPage:(CGFloat)page {
    CGFloat finalPageThreshold = ([_morsel.items count] + 1) - .5f;
    if (page > .5f && page < finalPageThreshold) {
        [self setupMorselLayout];
    } else if (page <= .5f) {
        [self setupCoverLayout];
    } else if (page >= finalPageThreshold) {
        [self setupShareLayout];
    }
}

#pragma mark - Action Methods

- (IBAction)viewMore {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLItem *visibleMorsel = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        [[MRSLEventManager sharedManager] track:@"Tapped View More Description"
                                     properties:@{@"view": @"main_feed",
                                                  @"item_id": NSNullIfNil(visibleMorsel.itemID)}];
        MRSLModalDescriptionViewController *modalDescriptionVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalDescriptionViewController"];
        modalDescriptionVC.item = visibleMorsel;
        [self addChildViewController:modalDescriptionVC];
        [self.view addSubview:modalDescriptionVC.view];
    }
}

- (IBAction)displayComments {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLItem *visibleMorsel = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        [[MRSLEventManager sharedManager] track:@"Tapped Comments"
                                     properties:@{@"view": @"main_feed",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(visibleMorsel.itemID),
                                                  @"comment_count": NSNullIfNil(visibleMorsel.comment_count)}];
        UINavigationController *commentNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_Comments"];
        MRSLModalCommentsViewController *modalCommentsVC = [[commentNC viewControllers] firstObject];
        modalCommentsVC.item = visibleMorsel;
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:commentNC];
    }
}

- (IBAction)displayLikers {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLItem *visibleMorsel = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        [[MRSLEventManager sharedManager] track:@"Tapped Likes"
                                     properties:@{@"view": @"main_feed",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(visibleMorsel.itemID),
                                                  @"like_count": NSNullIfNil(visibleMorsel.like_count)}];
        MRSLModalLikersViewController *modalLikersVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalLikesViewController"];
        modalLikersVC.item = visibleMorsel;
        [self addChildViewController:modalLikersVC];
        [self.view addSubview:modalLikersVC.view];
    }
}

- (IBAction)displayShare {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLItem *visibleMorsel = nil;
        if (_isPresentingMorselLayout) {
            visibleMorsel = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        } else {
            visibleMorsel = [_morsel coverItem];
        }
        [[MRSLEventManager sharedManager] track:@"Tapped Share Morsel"
                                     properties:@{@"view": @"main_feed",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(visibleMorsel.itemID)}];
        MRSLModalShareViewController *modalShareVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalShareViewController"];
        modalShareVC.item = visibleMorsel;
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
    return collectionView.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentPage = scrollView.contentOffset.y / scrollView.frame.size.height;
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    self.pageControl.currentPage = (translation.y > 0) ? ceilf(currentPage - 1) : floorf(currentPage - 1);
    [self determineLayoutForPage:currentPage];
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
                                atScrollPosition:UICollectionViewScrollPositionNone
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
