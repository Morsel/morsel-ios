//
//  MRSLCollectionViewArraySectionsDataSource.m
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewArraySectionsDataSource.h"

@interface MRSLCollectionViewDataSource ()

@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSArray *sections;
@property (copy, nonatomic) MRSLCellConfigureBlock configureCellBlock;

@end

@interface MRSLCollectionViewArraySectionsDataSource ()

@property (copy, nonatomic) MRSLSupplementaryCellConfigureBlock supplementaryConfigureBlock;
@property (copy, nonatomic) MRSLLayoutCellSizeConfigureBlock cellSizeBlock;

@end

@implementation MRSLCollectionViewArraySectionsDataSource

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock {
    self = [super init];
    if (self) {
        self.objects = objects;
        self.sections = sectionsOrNil ?: @[[NSNull null]];
        self.configureCellBlock = [configureCellBlock copy];
        self.supplementaryConfigureBlock = supplementaryBlock;
        self.cellSizeBlock = cellSizeBlock;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = self.supplementaryConfigureBlock(collectionView, kind, indexPath);
    return reusableView;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (self.cellSizeBlock) ? self.cellSizeBlock(collectionView, indexPath) : CGSizeZero;
}

@end
