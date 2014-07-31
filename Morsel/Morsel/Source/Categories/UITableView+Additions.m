//
//  UITableView+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UITableView+Additions.h"

@implementation UITableView (Additions)

- (NSInteger)numberOfRowsInAllSections {
    NSUInteger rowCount = 0;
    for (NSInteger i = 0; i < [self numberOfSections]; i++)
        rowCount += [self numberOfRowsInSection:i];
    return rowCount;
}

- (BOOL)isFirstRowInSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0;
}

- (BOOL)isFirstSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (BOOL)isLastRowInSectionForIndexPath:(NSIndexPath *)indexPath {
    return [self numberOfRowsInSection:indexPath.section] - 1 == indexPath.row;
}

- (BOOL)isLastSectionForIndexPath:(NSIndexPath *)indexPath {
    return [self numberOfSections] - 1 == indexPath.section;
}

- (BOOL)isLastRowForIndexPath:(NSIndexPath *)indexPath {
    return [self isLastSectionForIndexPath:indexPath] && [self isLastRowInSectionForIndexPath:indexPath];
}

- (BOOL)hasHeaderForSection:(NSInteger)section {
    return [self.dataSource tableView:self
              titleForHeaderInSection:section] != nil;
}

@end
