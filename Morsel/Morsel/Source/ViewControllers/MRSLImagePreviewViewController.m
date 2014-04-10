//
//  MRSLPreviewMediaViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImagePreviewViewController.h"

#import "MRSLImagePreviewCollectionViewCell.h"

#import "MRSLMorsel.h"

@interface MRSLImagePreviewViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UICollectionView *previewMediaCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *previewMediaPageControl;

@property (nonatomic) NSUInteger currentIndex;

@property (strong, nonatomic) NSMutableArray *previewMedia;

@end

@implementation MRSLImagePreviewViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.previewMediaPageControl addTarget:self
                                    action:@selector(changePage:)
                          forControlEvents:UIControlEventValueChanged];

    [self setupControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)setPreviewMedia:(NSMutableArray *)media andStartingIndex:(NSUInteger)index {
    self.currentIndex = index;
    self.previewMedia = media;

    [self setupControls];
}

- (void)setupControls {
    id firstMediaItem = [_previewMedia firstObject];
    if ([firstMediaItem isKindOfClass:[MRSLMorsel class]]) {
        self.deleteButton.hidden = YES;
    }
    [self.previewMediaPageControl setNumberOfPages:[_previewMedia count]];
    [self.previewMediaPageControl setCurrentPage:_currentIndex];

    [self.previewMediaCollectionView reloadData];

    [self.previewMediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex
                                                                                 inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                    animated:NO];
    if ([_previewMedia count] == 1) [self updateControls];
}

- (void)updateControls {
    self.currentIndex = _previewMediaCollectionView.contentOffset.x / _previewMediaCollectionView.frame.size.width;

    [self.previewMediaPageControl setNumberOfPages:[_previewMedia count]];
    [self.previewMediaPageControl setCurrentPage:_currentIndex];
    self.previewMediaPageControl.hidden = ([_previewMedia count] == 1);

    self.previousButton.enabled = (_currentIndex != 0);
    self.previousButton.hidden = ([_previewMedia count] == 1);
    self.nextButton.enabled = (_currentIndex != [_previewMedia count] - 1);
    self.nextButton.hidden = ([_previewMedia count] == 1);
}

#pragma mark - Action Methods

- (IBAction)closeImagePreview {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)deleteMedia {
    if (_currentIndex > [_previewMedia count] - 1) self.currentIndex = [_previewMedia count] - 1;
    id objectToRemove = [_previewMedia objectAtIndex:_currentIndex];

    [_previewMedia removeObject:objectToRemove];
    [self.previewMediaCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currentIndex inSection:0]]];

    if ([self.delegate respondsToSelector:@selector(imagePreviewDidDeleteMedia)]) {
        [self.delegate imagePreviewDidDeleteMedia];
    }

    if ([_previewMedia count] == 0) {
        [self closeImagePreview];
    } else {
        [self updateControls];
    }
}

- (IBAction)displayPrevious {
    if (_currentIndex == 0) return;
    self.currentIndex = _currentIndex - 1;
    [self.previewMediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                    animated:YES];
}

- (IBAction)displayNext {
    if (_currentIndex == [_previewMedia count] - 1) return;
    self.currentIndex = _currentIndex + 1;

    [self.previewMediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                    animated:YES];
}

- (void)changePage:(UIPageControl *)pageControl {
    [self.previewMediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pageControl.currentPage inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                    animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_previewMedia count];
}

- (MRSLImagePreviewCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                                cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLImagePreviewCollectionViewCell *previewImageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MediaPreviewCell"
                                                                                                     forIndexPath:indexPath];
    previewImageCell.mediaPreviewItem = [_previewMedia objectAtIndex:indexPath.row];
    return previewImageCell;
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateControls];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self updateControls];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateControls];
}

@end
