//
//  MRSLDataSource.m
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

@property (copy, nonatomic) MRSLCellConfigureBlock configureCellBlock;

@end

@implementation MRSLCollectionViewDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
    }
    return self;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.objects count] == 0) return nil;
    return self.objects[(NSUInteger) indexPath.row];
}

- (NSUInteger)count {
    return [self.objects count];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self objectAtIndexPath:indexPath];
    return self.configureCellBlock(item, collectionView, indexPath, [self count]);
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self objectAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(collectionViewDataSource:didSelectItem:)]) {
        [self.delegate collectionViewDataSource:collectionView didSelectItem:item];
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if ([self.delegate respondsToSelector:@selector(collectionViewDataSourceDidScroll:withOffset:)]) {
        [self.delegate collectionViewDataSourceDidScroll:(UICollectionView *)scrollView withOffset:maximumOffset - currentOffset];
    }
}

@end
