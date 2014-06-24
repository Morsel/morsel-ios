//
//  MRSLCapturePreviewsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCapturePreviewsViewController.h"

#import "MRSLMediaItem.h"
#import "MRSLMediaItemPreviewCollectionViewCell.h"
#import "MRSLImagePreviewViewController.h"

@interface MRSLCapturePreviewsViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
MRSLImagePreviewViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *previewCollectionView;

@property (nonatomic) NSUInteger selectedIndex;

@property (strong, nonatomic) NSMutableArray *previewMediaItemThumbs;

@end

@implementation MRSLCapturePreviewsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_previewMediaItemThumbs) _previewMediaItemThumbs = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.previewCollectionView reloadData];
}

- (NSUInteger)thumbImageCount {
    return [_previewMediaItemThumbs count];
}

- (void)addPreviewMediaItem:(MRSLMediaItem *)mediaItem {
    if (mediaItem) {
        [self.previewMediaItemThumbs addObject:mediaItem];
        [self.previewCollectionView reloadData];

        NSInteger indexPathRow = [_previewMediaItemThumbs count] - 1;
        if (indexPathRow >= 0) {
            [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPathRow
                                                                                   inSection:0]
                                               atScrollPosition:UICollectionViewScrollPositionRight
                                                       animated:YES];
        }
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_DisplayImagePreview"]) {
        MRSLImagePreviewViewController *previewMediaVC = [segue destinationViewController];
        previewMediaVC.delegate = self;
        [previewMediaVC setPreviewMedia:_previewMediaItemThumbs
                       andStartingIndex:_selectedIndex];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_previewMediaItemThumbs count];
}

- (MRSLMediaItemPreviewCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMediaItem *mediaItem = [_previewMediaItemThumbs objectAtIndex:indexPath.row];

    MRSLMediaItemPreviewCollectionViewCell *mediaPreviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MediaItemCell"
                                                                                                         forIndexPath:indexPath];
    mediaPreviewCell.mediaItem = mediaItem;

    return mediaPreviewCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[MRSLEventManager sharedManager] track:@"Tapped Thumbnail"
                                 properties:@{@"view": @"Media Capture"}];
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"seg_DisplayImagePreview"
                              sender:nil];
}

#pragma mark - MRSLImagePreviewViewControllerDelegate

- (void)imagePreviewDidDeleteMediaItem:(MRSLMediaItem *)mediaItem {
    if ([self.delegate respondsToSelector:@selector(capturePreviewsDidDeleteMediaItem:)]) {
        [self.delegate capturePreviewsDidDeleteMediaItem:mediaItem];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    self.previewCollectionView.delegate = nil;
    self.previewCollectionView.dataSource = nil;
    [self.previewCollectionView removeFromSuperview];
    self.previewCollectionView = nil;
}

@end
