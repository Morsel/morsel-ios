//
//  MRSLPanelSegmentedDataSource.m
//  Morsel
//
//  Created by Javier Otero on 5/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPanelSegmentedCollectionViewDataSource.h"

@interface MRSLCollectionViewDataSource ()

@property (strong, nonatomic) NSArray *objects;

@end

@interface MRSLPanelSegmentedCollectionViewDataSource ()

@property (copy, nonatomic) MRSLSupplementaryCellConfigureBlock supplementaryConfigureBlock;
@end

@implementation MRSLPanelSegmentedCollectionViewDataSource

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionViewDataSourceNumberOfItemsInSection:)]) {
        return [self.delegate collectionViewDataSourceNumberOfItemsInSection:section];
    } else {
        return (section == 0) ? 1 : ([self.objects count] ?: 0);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = self.supplementaryConfigureBlock(collectionView, kind, indexPath);
    return reusableView;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section != 0);
}

@end
