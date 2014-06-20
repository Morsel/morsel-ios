//
//  MRSLTableViewDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTableViewDataSource.h"

@interface MRSLDataSource ()

@property (strong, nonatomic) id objects;

@end

@interface MRSLTableViewDataSource ()

@property (copy, nonatomic) MRSLCellConfigureBlock configureCellBlock;

@end

@implementation MRSLTableViewDataSource

- (id)initWithObjects:(id)objects
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock {
    self = [super initWithObjects:objects];
    if (self) {
        self.configureCellBlock = [configureCellBlock copy];
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:didSelectItem:)]) {
        [self.delegate tableViewDataSource:tableView didSelectItem:[self objectAtIndexPath:indexPath]];
    }
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:didSelectItemAtIndexPath:)]) {
        [self.delegate tableViewDataSource:tableView didSelectItemAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:heightForItemAtIndexPath:)]) {
        return [self.delegate tableViewDataSource:tableView heightForItemAtIndexPath:indexPath];
    }
    return 40.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSourceNumberOfItemsInSection:)]) {
        return [self.delegate tableViewDataSourceNumberOfItemsInSection:section];
    } else {
        return [self count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = self.configureCellBlock([self objectAtIndexPath:indexPath], tableView, indexPath, [self count]);
    [tableViewCell setBorderWithDirections:MRSLBorderSouth
                               borderWidth:1.f
                            andBorderColor:[UIColor morselLightOffColor]];
    return tableViewCell;
}

@end
