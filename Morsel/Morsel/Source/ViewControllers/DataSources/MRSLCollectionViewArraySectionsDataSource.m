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
@property (copy, nonatomic) MRSLLayoutSectionSizeConfigureBlock sectionSizeBlock;
@property (copy, nonatomic) MRSLLayoutCellSizeConfigureBlock cellSizeBlock;

@end

@implementation MRSLCollectionViewArraySectionsDataSource

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock {
    return [self initWithObjects:objects
                        sections:sectionsOrNil
              configureCellBlock:configureCellBlock
              supplementaryBlock:supplementaryBlock
                sectionSizeBlock:nil
                   cellSizeBlock:cellSizeBlock];
}

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
     sectionSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionSizeBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock {
    self = [super init];
    if (self) {
        self.objects = objects;
        self.sections = sectionsOrNil ?: @[[NSNull null]];
        self.configureCellBlock = [configureCellBlock copy];
        self.supplementaryConfigureBlock = supplementaryBlock;
        self.sectionSizeBlock = sectionSizeBlock;
        self.cellSizeBlock = cellSizeBlock;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    return (_supplementaryConfigureBlock) ? _supplementaryConfigureBlock(collectionView, kind, indexPath) : nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (_cellSizeBlock) ? _cellSizeBlock(collectionView, indexPath) : CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return (_sectionSizeBlock) ? _sectionSizeBlock(collectionView, section) : CGSizeZero;
}

@end
