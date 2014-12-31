//
//  MRSLCollectionViewDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewDataSource.h"

#import "MRSLStatusHeaderCollectionReusableView.h"

@interface MRSLCollectionViewDataSource ()

@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSArray *sections;

@property (copy, nonatomic) MRSLCVCellConfigureBlock configureCellBlock;
@property (copy, nonatomic) MRSLSupplementaryCellConfigureBlock supplementaryConfigureBlock;
@property (copy, nonatomic) MRSLLayoutSectionSizeConfigureBlock sectionHeaderSizeBlock;
@property (copy, nonatomic) MRSLLayoutSectionSizeConfigureBlock sectionFooterSizeBlock;
@property (copy, nonatomic) MRSLLayoutCellSizeConfigureBlock cellSizeBlock;
@property (copy, nonatomic) MRSLLayoutSectionInsetConfigureBlock sectionEdgeInsetsBlock;

@end

@implementation MRSLCollectionViewDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
    }
    return self;
}

- (id)initWithObjects:(id)objects
   configureCellBlock:(MRSLCVCellConfigureBlock)configureCellBlock {
    self = [super initWithObjects:objects];
    if (self) {
        self.configureCellBlock = [configureCellBlock copy];
    }
    return self;
}

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCVCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
sectionHeaderSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionHeaderSizeBlock
sectionFooterSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionFooterSizeBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock
   sectionInsetConfig:(MRSLLayoutSectionInsetConfigureBlock)insetConfig {
    self = [super init];
    if (self) {
        self.objects = objects;
        self.sections = sectionsOrNil ?: @[[NSNull null]];
        self.configureCellBlock = [configureCellBlock copy];
        self.supplementaryConfigureBlock = supplementaryBlock;
        self.sectionHeaderSizeBlock = sectionHeaderSizeBlock;
        self.sectionFooterSizeBlock = sectionFooterSizeBlock;
        self.cellSizeBlock = cellSizeBlock;
        self.sectionEdgeInsetsBlock = insetConfig;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (self.sections) ? [self.sections count] : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionViewDataSourceNumberOfItemsInSection:)]) {
        return [self.delegate collectionViewDataSourceNumberOfItemsInSection:section];
    } else {
        return [self count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self objectAtIndexPath:indexPath];
    return self.configureCellBlock(item, collectionView, indexPath, [self count]);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    return (self.supplementaryConfigureBlock) ? self.supplementaryConfigureBlock(collectionView, kind, indexPath) : [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MRSLStoryboardRUIDSectionHeaderKey forIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self objectAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(collectionViewDataSource:didSelectItem:)]) {
        [self.delegate collectionViewDataSource:collectionView didSelectItem:item];
    }
    if ([self.delegate respondsToSelector:@selector(collectionViewDataSource:didSelectItemAtIndexPath:)]) {
        [self.delegate collectionViewDataSource:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return (self.sectionFooterSizeBlock) ? self.sectionFooterSizeBlock(collectionView, section) : CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return (self.sectionHeaderSizeBlock) ? self.sectionHeaderSizeBlock(collectionView, section) : CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (self.cellSizeBlock) ? self.cellSizeBlock(collectionView, indexPath) : CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return (self.sectionEdgeInsetsBlock) ? self.sectionEdgeInsetsBlock(collectionView, section) : UIEdgeInsetsZero;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if ([self.delegate respondsToSelector:@selector(collectionViewDataSourceDidScroll:withOffset:)]) {
        [self.delegate collectionViewDataSourceDidScroll:(UICollectionView *)scrollView withOffset:maximumOffset - currentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

@end
