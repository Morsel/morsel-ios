//
//  MorselThumbnailViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselThumbnailViewController.h"

#import "MorselThumbnailCollectionViewCell.h"

#import "MRSLPost.h"

@interface MorselThumbnailViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *thumbnailCollectionView;

@end

@implementation MorselThumbnailViewController

#pragma mark - Instance Methods

- (void)setPost:(MRSLPost *)post {
    if (_post != post) {
        _post = post;

        [self.thumbnailCollectionView reloadData];
    }
}

#pragma mark - Private Methods

- (IBAction)close {
    if ([self.delegate respondsToSelector:@selector(morselThumbnailDidSelectClose)]) {
        [self.delegate morselThumbnailDidSelectClose];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_post.morsels count];
}

- (MorselThumbnailCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                              cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_post.morsels objectAtIndex:indexPath.row];

    MorselThumbnailCollectionViewCell *morselCell = [self.thumbnailCollectionView dequeueReusableCellWithReuseIdentifier:@"MorselCell"
                                                                                                            forIndexPath:indexPath];
    morselCell.morsel = morsel;

    return morselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(morselThumbnailDidSelectMorsel:)]) {
        MRSLMorsel *morsel = [_post.morsels objectAtIndex:indexPath.row];

        [self.delegate morselThumbnailDidSelectMorsel:morsel];
    }
}

@end
