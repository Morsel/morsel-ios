//
//  MRSLArrayDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewArrayDataSource.h"

@interface MRSLCollectionViewDataSource ()

@property (strong, nonatomic) NSArray *objects;
@property (copy, nonatomic) MRSLCellConfigureBlock configureCellBlock;

@end

@implementation MRSLCollectionViewArrayDataSource

- (id)initWithObjects:(NSArray *)objects
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock {
    self = [super init];
    if (self) {
        self.objects = objects;
        self.configureCellBlock = [configureCellBlock copy];
    }
    return self;
}

- (void)updateObjects:(NSArray *)newItems {
    self.objects = newItems;
}

@end
