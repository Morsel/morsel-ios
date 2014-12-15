//
//  MRSLPanelSegmentedDataSource.h
//  Morsel
//
//  Created by Javier Otero on 5/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewFetchResultsDataSource.h"

@interface MRSLPanelSegmentedCollectionViewDataSource : MRSLCollectionViewFetchResultsDataSource
<UICollectionViewDelegateFlowLayout>

- (id)initWithManagedObjectClass:(Class)objectClass
                       predicate:(NSPredicate *)predicateOrNil
                  collectionView:(UICollectionView *)collectionView
                      cellConfig:(MRSLCVCellConfigureBlock)cellConfig
             supplementaryConfig:(MRSLSupplementaryCellConfigureBlock)supplementaryConfig
                    headerConfig:(MRSLLayoutHeaderSizeConfigureBlock)headerConfig
                  cellSizeConfig:(MRSLLayoutCellSizeConfigureBlock)cellSizeConfig
              sectionInsetConfig:(MRSLLayoutSectionInsetConfigureBlock)insetConfig;

@end
