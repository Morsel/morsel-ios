//
//  MRSLDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLDataSource.h"

#import "MRSLStatusHeaderCollectionReusableView.h"

@interface MRSLDataSource ()

@property (strong, nonatomic) NSArray *objects;
@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) MRSLCellConfigureBlock configureCellBlock;

@end

@implementation MRSLDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return self.objects[(NSUInteger) indexPath.row];
}

- (NSUInteger)count {
    return [self.objects count];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                                           forIndexPath:indexPath];
    id item = [self objectAtIndexPath:indexPath];
    self.configureCellBlock(cell, item, indexPath, [self count]);
    return cell;
}

@end
