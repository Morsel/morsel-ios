//
//  MRSLArrayDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLDataSource.h"

@interface MRSLArrayDataSource : MRSLDataSource

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(MRSLCellConfigureBlock)aConfigureCellBlock;

- (void)updateItems:(NSArray *)newItems;

@end
