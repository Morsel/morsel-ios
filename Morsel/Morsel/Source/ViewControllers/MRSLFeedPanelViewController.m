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
#import "MRSLStoryEditViewController.h"
#import "MRSLProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
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
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
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
    [self.storyTitleLabel addStandardShadow];
}

- (void)setPost:(MRSLPost *)post {
    if (_post != post) {
        _post = post;
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

#pragma mark - Private Methods

- (void)displayContent {
    if (_collectionView && _post) {
        self.view.backgroundColor = [UIColor whiteColor];

        self.profileImageView.user = _post.creator;

        self.userNameLabel.text = _post.creator.fullName;
        self.userNameLabel.textColor = [UIColor morselDarkContent];

        self.pageControl.alpha = 0.f;
        self.pageControl.numberOfPages = [_post.morsels count];
        self.pageControl.hidden = !([_post.morsels count] > 1);
        [self.pageControl setY:[self.view getHeight] - ((([_pageControl sizeForNumberOfPages:_pageControl.numberOfPages].width) / 2) + 34.f)];
        self.pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);

        self.storyTitleLabel.text = _post.title;
        [self.storyTitleLabel setX:30.f];
        [self.storyTitleLabel setY:86.f];
        [self.storyTitleLabel setHeight:140.f];
        [self.storyTitleLabel setWidth:260.f];
        [self.storyTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:32.f]];

        self.timeSinceLabel.text = [_post.lastUpdatedDate timeAgo];

        [self.collectionView reloadData];
        [self resetCollectionViewContentOffset:NO];

        CGFloat currentPage = _collectionView.contentOffset.y / _collectionView.frame.size.height;
        [self determineLayoutForPage:currentPage];
    }
}

- (void)toggleContent:(BOOL)shouldDisplay {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [_storyTitleLabel setAlpha:shouldDisplay];
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

    [self.storyTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:32.f]];
    [self.storyTitleLabel setHeight:140.f];
    [self.storyTitleLabel setWidth:260.f];

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.userNameLabel setTextColor:[UIColor morselDarkContent]];
                         [self.storyTitleLabel setX:30.f];
                         [self.storyTitleLabel setY:(![UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) ? 66.f : 86.f];
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

    [self.storyTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:17.f]];
    CGSize storyTitleLabelSize = [self.storyTitleLabel.text sizeWithFont:_storyTitleLabel.font constrainedToSize:CGSizeMake(212.f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    [self.storyTitleLabel setHeight:storyTitleLabelSize.height];
    [self.storyTitleLabel setWidth:212.f];

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.userNameLabel setTextColor:[UIColor morselLightOffColor]];
                         [self.storyTitleLabel setX:54.f];
                         [self.storyTitleLabel setY:(![UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) ? 8.f : 28.f];
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
    CGFloat finalPageThreshold = ([_post.morsels count] + 1) - .5f;
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
        MRSLMorsel *visibleMorsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        [[MRSLEventManager sharedManager] track:@"Tapped View More Description"
                                     properties:@{@"view": @"main_feed",
                                                  @"morsel_id": NSNullIfNil(visibleMorsel.morselID)}];
        MRSLModalDescriptionViewController *modalDescriptionVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalDescriptionViewController"];
        modalDescriptionVC.morsel = visibleMorsel;
        [self addChildViewController:modalDescriptionVC];
        [self.view addSubview:modalDescriptionVC.view];
    }
}

- (IBAction)displayComments {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLMorsel *visibleMorsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        [[MRSLEventManager sharedManager] track:@"Tapped Comments"
                                     properties:@{@"view": @"main_feed",
                                                  @"post_id": NSNullIfNil(_post.postID),
                                                  @"morsel_id": NSNullIfNil(visibleMorsel.morselID),
                                                  @"comment_count": NSNullIfNil(visibleMorsel.comment_count)}];
        MRSLModalCommentsViewController *modalCommentsVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalCommentsViewController"];
        modalCommentsVC.morsel = visibleMorsel;
        [self addChildViewController:modalCommentsVC];
        [self.view addSubview:modalCommentsVC.view];
    }
}

- (IBAction)displayLikers {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLMorsel *visibleMorsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        [[MRSLEventManager sharedManager] track:@"Tapped Likes"
                                     properties:@{@"view": @"main_feed",
                                                  @"post_id": NSNullIfNil(_post.postID),
                                                  @"morsel_id": NSNullIfNil(visibleMorsel.morselID),
                                                  @"like_count": NSNullIfNil(visibleMorsel.like_count)}];
        MRSLModalLikersViewController *modalLikersVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalLikesViewController"];
        modalLikersVC.morsel = visibleMorsel;
        [self addChildViewController:modalLikersVC];
        [self.view addSubview:modalLikersVC.view];
    }
}

- (IBAction)displayShare {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLMorsel *visibleMorsel = nil;
        if (_isPresentingMorselLayout) {
            visibleMorsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        } else {
            visibleMorsel = [_post coverMorsel];
        }
        [[MRSLEventManager sharedManager] track:@"Tapped Share Morsel"
                                     properties:@{@"view": @"main_feed",
                                                  @"post_id": NSNullIfNil(_post.postID),
                                                  @"morsel_id": NSNullIfNil(visibleMorsel.morselID)}];
        MRSLModalShareViewController *modalShareVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalShareViewController"];
        modalShareVC.morsel = visibleMorsel;
        [self addChildViewController:modalShareVC];
        [self.view addSubview:modalShareVC.view];
    }
}


- (IBAction)editStory {
    UINavigationController *storyEditNC = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_StoryEdit"];
    MRSLStoryEditViewController *storyEditVC = [[storyEditNC viewControllers] firstObject];
    storyEditVC.postID = _post.postID;
    [self presentViewController:storyEditNC
                       animated:YES
                     completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_post.morsels count] + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.row == 0) {
        MRSLFeedCoverCollectionViewCell *storyCoverCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_StoryCoverCell"
                                                                                                    forIndexPath:indexPath];
        storyCoverCell.post = _post;
        storyCoverCell.delegate = self;
        cell = storyCoverCell;
    } else if (indexPath.row == [_post.morsels count] + 1) {
        MRSLFeedShareCollectionViewCell *shareCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_StoryShareCell"
                                                                                                    forIndexPath:indexPath];
        shareCell.post = _post;
        shareCell.delegate = self;
        cell = shareCell;
    } else {
        MRSLFeedPageCollectionViewCell *storyPageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_StoryPageCell"
                                                                                                  forIndexPath:indexPath];
        storyPageCell.morsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        cell = storyPageCell;
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
    if (indexPath) {
        MRSLMorsel *visibleMorsel = nil;
        if (_isPresentingMorselLayout && indexPath.row != 0) {
            visibleMorsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        } else {
            visibleMorsel = [_post coverMorsel];
        }
        CGFloat currentPage = scrollView.contentOffset.y / scrollView.frame.size.height;
        BOOL onShare = (currentPage == [_post.morsels count] + 2);

        if (_scrollDirection == MRSLScrollDirectionDown) {
            [[MRSLEventManager sharedManager] track:@"Scroll Post Down"
                                         properties:@{@"view": @"main_feed",
                                                      @"post_id": NSNullIfNil(visibleMorsel.post.postID),
                                                      @"morsel_id": NSNullIfNil(visibleMorsel.morselID),
                                                      @"on_share": (onShare) ? @"true" : @"false",
                                                      @"morsel_scroll_index": NSNullIfNil(@(currentPage))}];
        } else if (_scrollDirection == MRSLScrollDirectionUp) {
            [[MRSLEventManager sharedManager] track:@"Scroll Post Up"
                                         properties:@{@"view": @"main_feed",
                                                      @"post_id": NSNullIfNil(visibleMorsel.post.postID),
                                                      @"morsel_id": NSNullIfNil(visibleMorsel.morselID),
                                                      @"on_share": (onShare) ? @"true" : @"false",
                                                      @"morsel_scroll_index": NSNullIfNil(@(currentPage))}];
        }
    }
}

#pragma mark - MRSLFeedCoverCollectionViewCellDelegate

- (void)feedCoverCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel {
    NSInteger morselIndex = [_post.morselsArray indexOfObject:morsel] + 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:morselIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:YES];
}

#pragma mark - MRSLFeedShareCollectionViewCellDelegate

- (void)feedShareCollectionViewCellDidSelectShareFacebook {
    [[MRSLSocialService sharedService] shareMorselToFacebook:[_post coverMorsel]
                                            inViewController:self
                                                     success:nil
                                                      cancel:nil];
}

- (void)feedShareCollectionViewCellDidSelectShareTwitter {
    [[MRSLSocialService sharedService] shareMorselToTwitter:[_post coverMorsel]
                                           inViewController:self
                                                    success:nil
                                                     cancel:nil];
}

- (void)feedShareCollectionViewCellDidSelectPreviousStory {
    if ([self.delegate respondsToSelector:@selector(feedPanelViewControllerDidSelectPreviousStory)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetCollectionViewContentOffset:YES];
        });
        [self.delegate feedPanelViewControllerDidSelectPreviousStory];
    }
}

- (void)feedShareCollectionViewCellDidSelectNextStory {
    if ([self.delegate respondsToSelector:@selector(feedPanelViewControllerDidSelectNextStory)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetCollectionViewContentOffset:YES];
        });
        [self.delegate feedPanelViewControllerDidSelectNextStory];
    }
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
