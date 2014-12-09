//
//  MRSLArrayDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewDataSource.h"

@interface MRSLCollectionViewArrayDataSource : MRSLCollectionViewDataSource

- (id)initWithObjects:(NSArray *)objects
   configureCellBlock:(MRSLCVCellConfigureBlock)configureCellBlock;

- (void)updateObjects:(NSArray *)newObjects;

@end
