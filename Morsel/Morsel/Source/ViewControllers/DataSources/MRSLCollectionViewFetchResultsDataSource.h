//
//  MRSLCollectionViewFetchResultsDataSource.h
//  Morsel
//
//  Created by Javier Otero on 5/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewDataSource.h"

@interface MRSLCollectionViewFetchResultsDataSource : MRSLCollectionViewDataSource
<NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL ascending;

@property (nonatomic) MRSLDataSortType sortType;

- (id)initWithManagedObjectClass:(Class)objectClass
                       predicate:(NSPredicate *)predicateOrNil
              configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
                  collectionView:(UICollectionView *)collectionView;

- (void)updateFetchRequestWithManagedObjectClass:(Class)objectClass
                                   withPredicate:(NSPredicate *)predicateOrNil;

- (void)updateDataSortType:(MRSLDataSortType)sortType;

@end
