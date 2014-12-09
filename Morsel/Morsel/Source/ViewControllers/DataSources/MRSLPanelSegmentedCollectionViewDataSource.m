//
//  MRSLPanelSegmentedDataSource.m
//  Morsel
//
//  Created by Javier Otero on 5/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPanelSegmentedCollectionViewDataSource.h"

@interface MRSLCollectionViewDataSource ()

@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *objects;

@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) MRSLCVCellConfigureBlock configureCellBlock;

@end

@interface MRSLPanelSegmentedCollectionViewDataSource ()

@property (copy, nonatomic) MRSLSupplementaryCellConfigureBlock supplementaryConfigureBlock;
@property (copy, nonatomic) MRSLLayoutHeaderSizeConfigureBlock headerSizeBlock;
@property (copy, nonatomic) MRSLLayoutCellSizeConfigureBlock cellSizeBlock;
@property (copy, nonatomic) MRSLLayoutSectionInsetConfigureBlock sectionEdgeInsetsBlock;

@end

@implementation MRSLPanelSegmentedCollectionViewDataSource

- (id)initWithManagedObjectClass:(Class)objectClass
                       predicate:(NSPredicate *)predicateOrNil
                  collectionView:(UICollectionView *)collectionView
                      cellConfig:(MRSLCVCellConfigureBlock)cellConfig
             supplementaryConfig:(MRSLSupplementaryCellConfigureBlock)supplementaryConfig
                    headerConfig:(MRSLLayoutHeaderSizeConfigureBlock)headerConfig
                  cellSizeConfig:(MRSLLayoutCellSizeConfigureBlock)cellSizeConfig
              sectionInsetConfig:(MRSLLayoutSectionInsetConfigureBlock)insetConfig {
    self = [super initWithManagedObjectClass:objectClass
                                   predicate:predicateOrNil
                          configureCellBlock:cellConfig
                              collectionView:collectionView];
    if (self) {
        self.collectionView = collectionView;
        self.configureCellBlock = cellConfig;
        self.supplementaryConfigureBlock = supplementaryConfig;
        self.headerSizeBlock = headerConfig;
        self.cellSizeBlock = cellSizeConfig;
        self.sectionEdgeInsetsBlock = insetConfig;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (section == 0) ? 1 : ([self.objects count] ?: 0);
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

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return (self.headerSizeBlock) ? self.headerSizeBlock(collectionView, section) : CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (self.cellSizeBlock) ? self.cellSizeBlock(collectionView, indexPath) : CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return (self.sectionEdgeInsetsBlock) ? self.sectionEdgeInsetsBlock(collectionView, section) : UIEdgeInsetsZero;
}

@end
