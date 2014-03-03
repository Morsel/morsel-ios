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
UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *previewCollectionView;

@property (nonatomic) NSUInteger selectedIndex;

@property (strong, nonatomic) NSMutableArray *previewMediaItems;

@end

@implementation MRSLCapturePreviewsViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.previewCollectionView reloadData];
}

- (void)addPreviewMediaItems:(NSMutableArray *)previewMediaItems {
    self.previewMediaItems = previewMediaItems;
    
    [self.previewCollectionView reloadData];

    [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[_previewMediaItems count] - 1 inSection:0]
                                       atScrollPosition:UICollectionViewScrollPositionRight
                                               animated:YES];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_DisplayImagePreview"]) {
        MRSLImagePreviewViewController *previewMediaVC = [segue destinationViewController];
        [previewMediaVC setPreviewMedia:_previewMediaItems
                       andStartingIndex:_selectedIndex];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_previewMediaItems count];
}

- (MRSLMediaItemPreviewCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMediaItem *mediaItem = [_previewMediaItems objectAtIndex:indexPath.row];

    MRSLMediaItemPreviewCollectionViewCell *mediaPreviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MediaItemCell"
                                                                                                         forIndexPath:indexPath];
    mediaPreviewCell.mediaItem = mediaItem;

    return mediaPreviewCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"seg_DisplayImagePreview"
                              sender:nil];
}

@end
