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
#import "MRSLProfileImageView.h"

#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLFeedPanelViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayContent];
}

- (void)setPost:(MRSLPost *)post {
    _post = post;
    [self displayContent];
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
        self.pageControl.numberOfPages = [_post.morsels count];
        self.pageControl.hidden = !([_post.morsels count] > 1);
        [self.pageControl setY:[self.view getHeight] - ((([_pageControl sizeForNumberOfPages:_pageControl.numberOfPages].width) / 2) + 34.f)];
        self.pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);
        
        [self.collectionView reloadData];
    }
}

- (void)setupCoverLayout {
    if (_isPresentingMorselLayout) {
        self.isPresentingMorselLayout = NO;
    } else {
        return;
    }
    [UIView animateWithDuration:.2f animations:^{
        [self.userNameLabel setTextColor:[UIColor morselDarkContent]];
        [self.storyTitleLabel setX:30.f];
        [self.storyTitleLabel setY:86.f];
        [self.storyTitleLabel setHeight:140.f];
        [self.storyTitleLabel setWidth:260.f];
        [self.storyTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:24.f]];
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
    CGSize smallTitleSize = [_storyTitleLabel.text sizeWithFont:_storyTitleLabel.font
                                              constrainedToSize:CGSizeMake(212.f, CGFLOAT_MAX)
                                                  lineBreakMode:NSLineBreakByWordWrapping];
    [UIView animateWithDuration:.2f animations:^{
        [self.userNameLabel setTextColor:[UIColor morselLightContent]];
        [self.storyTitleLabel setX:54.f];
        [self.storyTitleLabel setY:8.f];
        [self.storyTitleLabel setHeight:MAX(smallTitleSize.height, 63.f)];
        [self.storyTitleLabel setWidth:212.f];
        [self.storyTitleLabel setFont:[UIFont robotoSlabBoldFontOfSize:17.f]];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_post.morsels count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.row == 0) {
        MRSLFeedCoverCollectionViewCell *storyCoverCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_StoryCoverCell"
                                                                                                    forIndexPath:indexPath];
        storyCoverCell.post = _post;
        cell = storyCoverCell;
    } else {
        MRSLFeedPageCollectionViewCell *storyPageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_StoryPageCell"
                                                                                                  forIndexPath:indexPath];
        storyPageCell.morsel = [_post.morselsArray objectAtIndex:indexPath.row - 1];
        cell = storyPageCell;
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentPage = scrollView.contentOffset.y / scrollView.frame.size.height;
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    self.pageControl.currentPage = (translation.y > 0) ? ceilf(currentPage - 1) : floorf(currentPage - 1);
    if (currentPage > 0.5f) {
        [self setupMorselLayout];
    } else if (currentPage <= .5f) {
        [self setupCoverLayout];
    }
}

@end
