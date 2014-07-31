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
@property (copy, nonatomic) MRSLLayoutSectionSizeConfigureBlock sectionHeaderSizeBlock;
@property (copy, nonatomic) MRSLLayoutSectionSizeConfigureBlock sectionFooterSizeBlock;
@property (copy, nonatomic) MRSLLayoutCellSizeConfigureBlock cellSizeBlock;

@end

@implementation MRSLCollectionViewArraySectionsDataSource

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
sectionHeaderSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionHeaderSizeBlock
sectionFooterSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionFooterSizeBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock {
    self = [super init];
    if (self) {
        self.objects = objects;
        self.sections = sectionsOrNil ?: @[[NSNull null]];
        self.configureCellBlock = [configureCellBlock copy];
        self.supplementaryConfigureBlock = supplementaryBlock;
        self.sectionHeaderSizeBlock = sectionHeaderSizeBlock;
        self.sectionFooterSizeBlock = sectionFooterSizeBlock;
        self.cellSizeBlock = cellSizeBlock;
    }
    return self;
}

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
     sectionHeaderSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionHeaderSizeBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock {
    return [self initWithObjects:objects
                        sections:sectionsOrNil
              configureCellBlock:configureCellBlock
              supplementaryBlock:supplementaryBlock
          sectionHeaderSizeBlock:sectionHeaderSizeBlock
                   sectionFooterSizeBlock:nil
                   cellSizeBlock:cellSizeBlock];
}

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock {
    return [self initWithObjects:objects
                        sections:sectionsOrNil
              configureCellBlock:configureCellBlock
              supplementaryBlock:supplementaryBlock
          sectionHeaderSizeBlock:nil
          sectionFooterSizeBlock:nil
                   cellSizeBlock:cellSizeBlock];
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
    return (_sectionHeaderSizeBlock) ? _sectionHeaderSizeBlock(collectionView, section) : CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return (_sectionFooterSizeBlock) ? _sectionFooterSizeBlock(collectionView, section) : CGSizeZero;
}

@end
