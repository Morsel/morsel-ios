//
//  MRSLPreviewMediaViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMediaItemPreviewViewController.h"

#import "MRSLAPIService+Item.h"
#import "MRSLAPIService+Morsel.h"

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

@property (nonatomic) BOOL isDisplayingItems;

@property (weak, nonatomic) IBOutlet UICollectionView *previewMediaCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *previewMediaPageControl;
@property (weak, nonatomic) IBOutlet MRSLToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISwitch *coverSwitch;
@property (weak, nonatomic) IBOutlet UILabel *coverLabel;

@property (nonatomic) NSUInteger currentIndex;

@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSMutableArray *previewMedia;

@end

@implementation MRSLMediaItemPreviewViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.previewMediaPageControl addTarget:self
                                     action:@selector(changePage:)
                           forControlEvents:UIControlEventValueChanged];
    self.previewMediaPageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);

    [self setupControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_previewMedia count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.previewMediaCollectionView reloadData];
        });
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                style:UIBarButtonItemStyleDone
                                                                               target:self
                                                                               action:@selector(closeImagePreview)]];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-transparent"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:nil];
    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (void)setPreviewMedia:(NSMutableArray *)media andStartingIndex:(NSUInteger)index {
    self.currentIndex = index;
    self.previewMedia = media;

    [self setupControls];
}

#pragma mark - Private Methods

- (void)closeImagePreview {
    if (self.presentingViewController && [self.navigationController.viewControllers count] == 1) {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupControls {
    id firstMediaItem = [_previewMedia firstObject];
    self.isDisplayingItems = [firstMediaItem isKindOfClass:[MRSLItem class]];

    if (_isDisplayingItems) {
        self.title = @"Morsel checklist";
        self.mp_eventView = @"morsel_checklist";
        self.cellIdentifier = MRSLStoryboardRUIDItemPreviewCellKey;
    } else {
        self.title = @"Image preview";
        self.mp_eventView = @"image_preview";
        self.coverSwitch.hidden = YES;
        self.coverLabel.hidden = YES;
        self.cellIdentifier = MRSLStoryboardRUIDMediaPreviewCellKey;
    }

    [self.previewMediaPageControl setNumberOfPages:[_previewMedia count]];
    [self.previewMediaPageControl setCurrentPage:_currentIndex];
    [self.previewMediaPageControl setY:320.f - ((([_previewMediaPageControl sizeForNumberOfPages:_previewMediaPageControl.numberOfPages].width) / 2) + 34.f)];

    [self.previewMediaCollectionView reloadData];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.previewMediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex
                                                                                    inSection:0]
                                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                        animated:NO];
    });

    if ([_previewMedia count] == 1) [self updateControls];
}

- (void)updateControls {
    self.currentIndex = _previewMediaCollectionView.contentOffset.y / _previewMediaCollectionView.frame.size.height;

    [self.previewMediaPageControl setNumberOfPages:[_previewMedia count]];
    [self.previewMediaPageControl setCurrentPage:_currentIndex];
    self.previewMediaPageControl.hidden = ([_previewMedia count] == 1);
    [self.previewMediaPageControl setY:320.f - ((([_previewMediaPageControl sizeForNumberOfPages:_previewMediaPageControl.numberOfPages].width) / 2) + 34.f)];

    if (_isDisplayingItems) {
        MRSLItem *currentVisibleItem = [_previewMedia objectAtIndex:_currentIndex];
        BOOL currentItemIsCover = [currentVisibleItem isCoverItem];
        self.coverSwitch.enabled = !currentItemIsCover;
        [self.coverSwitch setOn:currentItemIsCover];
    }
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
    if ([segue.identifier isEqualToString:MRSLStoryboardSegueEditItemTextKey]) {
        MRSLItem *item = [_previewMedia objectAtIndex:_currentIndex];
        MRSLMorselEditDescriptionViewController *itemEditTextVC = [segue destinationViewController];
        itemEditTextVC.itemID = item.itemID;
    }
}

#pragma mark - Action Methods

- (IBAction)toggleCoverPhoto {
    MRSLItem *currentVisibleItem = [_previewMedia objectAtIndex:_currentIndex];
    currentVisibleItem.morsel.primary_item_id = currentVisibleItem.itemID;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService updateMorsel:currentVisibleItem.morsel
                                  success:nil
                                  failure:^(NSError *error) {
                                      if (weakSelf) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [weakSelf.coverSwitch setOn:NO];
                                              [UIAlertView showAlertViewForErrorString:@"Unable to set cover photo. Please try again."
                                                                              delegate:nil];
                                          });
                                      }
                                  }];
}

- (IBAction)editDescription {
    MRSLItem *item = [_previewMedia objectAtIndex:_currentIndex];
    if (!item.itemID) return;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Add Description",
                                              @"_view": self.mp_eventView,
                                              @"item_count": @([_previewMedia count]),
                                              @"morsel_id": NSNullIfNil(item.morsel.morselID),
                                              @"item_id": NSNullIfNil(item.itemID)}];
    [self performSegueWithIdentifier:MRSLStoryboardSegueEditItemTextKey
                              sender:nil];
}

- (IBAction)retakePhoto {
    MRSLCaptureSingleMediaViewController *captureMediaVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCaptureSingleMediaViewControllerKey];
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
                                            atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                    animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_previewMedia count];
}

- (MRSLImagePreviewCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                                cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLImagePreviewCollectionViewCell *previewImageCell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier
                                                                                                     forIndexPath:indexPath];
    previewImageCell.mediaPreviewItem = [_previewMedia objectAtIndex:indexPath.row];
    if (previewImageCell.itemPositionLabel) {
        NSInteger itemPosition = indexPath.row + 1;
        previewImageCell.itemPositionLabel.text = [NSString stringWithFormat:@"%li", (long)itemPosition];
    }
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

- (void)reset {
    [super reset];
    self.previewMediaCollectionView.delegate = nil;
    self.previewMediaCollectionView.dataSource = nil;
    [self.previewMediaCollectionView removeFromSuperview];
    self.previewMediaCollectionView = nil;
}

@end
