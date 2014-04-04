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
#import "MRSLModalCommentsViewController.h"
#import "MRSLModalDescriptionViewController.h"
#import "MRSLStoryEditViewController.h"
#import "MRSLProfileImageView.h"

#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedPanelViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
MRSLFeedCoverCollectionViewCellDelegate,
MRSLFeedShareCollectionViewCellDelegate>

@property (nonatomic) BOOL isPresentingMorselLayout;
@property (nonatomic) BOOL isDraggingScrollViewUp;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation MRSLFeedPanelViewController

#pragma mark - Instance Methods

- (void)setPost:(MRSLPost *)post {
    if (_post != post) {
        _post = post;
        [self displayContent];
    }
}

#pragma mark - Private Methods

- (void)displayContent {
    if (self.collectionView && self.post) {
        self.profileImageView.user = _post.creator;
        self.userNameLabel.text = _post.creator.fullName;
        self.userNameLabel.textColor = [UIColor morselDarkContent];
        self.timeSinceLabel.text = [_post.lastUpdatedDate timeAgo];
        self.storyTitleLabel.text = _post.title;
        [self.storyTitleLabel addStandardShadow];
        [self.pageControl setAlpha:0.f];
        self.pageControl.numberOfPages = [_post.morsels count];
        self.pageControl.hidden = !([_post.morsels count] > 1);
        [self.pageControl setY:[self.view getHeight] - ((([_pageControl sizeForNumberOfPages:_pageControl.numberOfPages].width) / 2) + 34.f)];
        self.pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);

        [self.storyTitleLabel setX:30.f];
        [self.storyTitleLabel setY:86.f];
        [self.storyTitleLabel setHeight:140.f];
        [self.storyTitleLabel setWidth:260.f];
        [self.userNameLabel setTextColor:[UIColor morselDarkContent]];
        [self.storyTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:32.f]];

        [self.collectionView reloadData];
        [self resetCollectionViewContentOffset:NO];
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)resetCollectionViewContentOffset:(BOOL)animated {
    [self.collectionView setContentOffset:CGPointMake(0.f, 0.f)
                                 animated:animated];
}

- (void)setupCoverLayout {
    if (_isPresentingMorselLayout) {
        self.isPresentingMorselLayout = NO;
    } else {
        return;
    }

    self.profileImageView.hidden = NO;
    self.userNameLabel.hidden = NO;
    self.timeSinceLabel.hidden = NO;

    [self.storyTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:32.f]];
    [self.storyTitleLabel setHeight:140.f];
    [self.storyTitleLabel setWidth:260.f];

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.userNameLabel setTextColor:[UIColor morselDarkContent]];
                         [self.storyTitleLabel setX:30.f];
                         [self.storyTitleLabel setY:86.f];
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
                         [self.storyTitleLabel setY:28.f];
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

#pragma mark - Action Methods

- (IBAction)viewMore {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLModalDescriptionViewController *modalDescriptionVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalDescriptionViewController"];
        modalDescriptionVC.morsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        [self addChildViewController:modalDescriptionVC];
        [self.view addSubview:modalDescriptionVC.view];
    }
}

- (IBAction)displayComments {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLModalCommentsViewController *modalCommentsVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLModalCommentsViewController"];
        modalCommentsVC.morsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        [self addChildViewController:modalCommentsVC];
        [self.view addSubview:modalCommentsVC.view];
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
    CGFloat finalPageThreshold = ([_post.morsels count] + 1) - .5f;
    if (currentPage > .5f && currentPage < finalPageThreshold) {
        [self setupMorselLayout];
    } else if (currentPage <= .5f) {
        [self setupCoverLayout];
    } else if (currentPage >= finalPageThreshold) {
        [self setupShareLayout];
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

@end
