//
//  MRSLArrayDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLArrayDataSource.h"

@interface MRSLDataSource ()

@property (strong, nonatomic) NSArray *objects;

@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) MRSLCellConfigureBlock configureCellBlock;

@end

@implementation MRSLArrayDataSource

- (id)initWithObjects:(NSArray *)objects
     cellIdentifier:(NSString *)cellIdentifier
 configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock {
    self = [super init];
    if (self) {
        self.objects = objects;
        self.cellIdentifier = cellIdentifier;
        self.configureCellBlock = [configureCellBlock copy];
    }
    return self;
}

- (void)updateObjects:(NSArray *)newItems {
    self.objects = newItems;
}

@end
