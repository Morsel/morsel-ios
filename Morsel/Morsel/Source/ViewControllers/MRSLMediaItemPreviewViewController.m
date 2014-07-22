//
//  MRSLPreviewMediaViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMediaItemPreviewViewController.h"

#import "MRSLAPIService+Item.h"

#import "MRSLCaptureSingleMediaViewController.h"
#import "MRSLImagePreviewCollectionViewCell.h"
#import "MRSLMorselEditDescriptionViewController.h"
#import "MRSLToolbar.h"

#import "MRSLMediaItem.h"
#import "MRSLMorsel.h"
#import "MRSLItem.h"

@interface MRSLMediaItemPreviewViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
CaptureMediaViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *previewMediaCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *previewMediaPageControl;
@property (weak, nonatomic) IBOutlet MRSLToolbar *toolbar;

@property (nonatomic) NSUInteger currentIndex;

@property (strong, nonatomic) NSMutableArray *previewMedia;

@end

@implementation MRSLMediaItemPreviewViewController

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
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
    if ([_previewMedia count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.previewMediaCollectionView reloadData];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)setPreviewMedia:(NSMutableArray *)media andStartingIndex:(NSUInteger)index {
    self.currentIndex = index;
    self.previewMedia = media;

    [self setupControls];
}

#pragma mark - Private Methods

- (void)closeImagePreview {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)setupControls {
    id firstMediaItem = [_previewMedia firstObject];

    if ([firstMediaItem isKindOfClass:[MRSLItem class]]) {
        self.title = @"Your Morsel";
        self.toolbar.leftButton.hidden = NO;
    } else {
        self.title = @"Image Preview";
        self.toolbar.leftButton.hidden = YES;
    }

    [self.previewMediaPageControl setNumberOfPages:[_previewMedia count]];
    [self.previewMediaPageControl setCurrentPage:_currentIndex];

    [self.previewMediaCollectionView reloadData];

    [self.previewMediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex
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
}

- (void)removeMediaItemAtCurrentIndex {
    if (_currentIndex > [_previewMedia count] - 1) self.currentIndex = [_previewMedia count] - 1;
    MRSLMediaItem *mediaItemToRemove = [_previewMedia objectAtIndex:_currentIndex];

    [_previewMedia removeObject:mediaItemToRemove];
    [self.previewMediaCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_currentIndex inSection:0]]];

    if ([self.delegate respondsToSelector:@selector(imagePreviewDidDeleteMediaItem:)]) {
        [self.delegate imagePreviewDidDeleteMediaItem:mediaItemToRemove];
    }

    if ([_previewMedia count] == 0) {
        [self closeImagePreview];
    } else {
        [self updateControls];
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_EditItemText"]) {
        MRSLItem *item = [_previewMedia objectAtIndex:_currentIndex];
        MRSLMorselEditDescriptionViewController *itemEditTextVC = [segue destinationViewController];
        itemEditTextVC.itemID = item.itemID;
    }
}

#pragma mark - Action Methods

- (IBAction)editDescription {
    MRSLItem *item = [_previewMedia objectAtIndex:_currentIndex];
    if (!item.itemID) return;
    [[MRSLEventManager sharedManager] track:@"Tapped Add Description"
                                 properties:@{@"view": @"Your Morsel",
                                              @"item_count": @([_previewMedia count]),
                                              @"morsel_id": NSNullIfNil(item.morsel.morselID),
                                              @"item_id": NSNullIfNil(item.itemID)}];
    [self performSegueWithIdentifier:@"seg_EditItemText"
                              sender:nil];
}

- (IBAction)retakePhoto {
    MRSLCaptureSingleMediaViewController *captureMediaVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLCaptureSingleMediaViewController"];
    captureMediaVC.delegate = self;
    [self presentViewController:captureMediaVC
                       animated:YES
                     completion:nil];
}

- (IBAction)deleteMedia {
    id firstMediaItem = [_previewMedia firstObject];
    if ([firstMediaItem isKindOfClass:[MRSLItem class]]) {
        [UIAlertView showAlertViewWithTitle:@"Delete Item"
                                    message:@"This will delete this item's photo and description. Are you sure you want to do this?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    } else {
        [self removeMediaItemAtCurrentIndex];
    }
}

- (void)changePage:(UIPageControl *)pageControl {
    [self.previewMediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:pageControl.currentPage inSection:0]
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

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320.f, [UIDevice has35InchScreen] ? 372.f : 460.f);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        MRSLItem *item = [_previewMedia objectAtIndex:_currentIndex];
        [_appDelegate.apiService deleteItem:item
                                    success:nil
                                    failure:nil];
        [self removeMediaItemAtCurrentIndex];
    }
}

#pragma mark - CaptureMediaViewControllerDelegate

- (void)captureMediaViewControllerDidFinishCapturingMediaItems:(NSMutableArray *)capturedMedia {
    MRSLMediaItem *mediaItem = [capturedMedia firstObject];
    MRSLItem *item = [_previewMedia objectAtIndex:_currentIndex];
    __weak __typeof(self) weakSelf = self;
    [mediaItem processMediaToDataWithSuccess:^(NSData *fullImageData, NSData *thumbImageData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            item.itemPhotoFull = fullImageData;
            item.itemPhotoThumb = thumbImageData;
            item.itemPhotoURL = nil;
            [item API_updateImage];
            [item.managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf.previewMediaCollectionView reloadData];
        });
    }];
}

#pragma mark - Dealloc

- (void)dealloc {
    self.previewMediaCollectionView.delegate = nil;
    self.previewMediaCollectionView.dataSource = nil;
    [self.previewMediaCollectionView removeFromSuperview];
    self.previewMediaCollectionView = nil;
}

@end
