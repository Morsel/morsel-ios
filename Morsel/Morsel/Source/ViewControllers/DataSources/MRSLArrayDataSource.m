//
//  MRSLArrayDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLArrayDataSource.h"

@interface MRSLDataSource ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) MRSLCellConfigureBlock configureCellBlock;

@end

@implementation MRSLArrayDataSource

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(MRSLCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        self.items = anItems;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (void)updateItems:(NSArray *)newItems {
    self.items = newItems;
}

@end
