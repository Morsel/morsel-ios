//
//  MRSLCollectionViewArraySectionsDataSource.h
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewArrayDataSource.h"

@interface MRSLCollectionViewArraySectionsDataSource : MRSLCollectionViewArrayDataSource

- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock;

@end
