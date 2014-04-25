//
//  MRSLArrayDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLDataSource.h"

@interface MRSLArrayDataSource : MRSLDataSource

- (id)initWithObjects:(NSArray *)objects
     cellIdentifier:(NSString *)cellIdentifier
 configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock;

- (void)updateObjects:(NSArray *)newObjects;

@end
