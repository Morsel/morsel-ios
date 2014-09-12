//
//  UICollectionView+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UICollectionView+Additions.h"

@implementation UICollectionView (Additions)

- (NSInteger)numberOfItemsInAllSections {
    NSUInteger rowCount = 0;
    for (NSInteger i = 0; i < [self numberOfSections]; i++)
        rowCount += [self numberOfItemsInSection:i];
    return rowCount;
}

- (BOOL)isFirstItemInSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0;
}

- (BOOL)isFirstSectionForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (BOOL)isLastItemInSectionForIndexPath:(NSIndexPath *)indexPath {
    return [self numberOfItemsInSection:indexPath.section] - 1 == indexPath.row;
}

- (BOOL)isLastSectionForIndexPath:(NSIndexPath *)indexPath {
    return [self lastSection] == indexPath.section;
}

- (BOOL)isLastItemForIndexPath:(NSIndexPath *)indexPath {
    return [self isLastSectionForIndexPath:indexPath] && [self isLastItemInSectionForIndexPath:indexPath];
}

- (NSInteger)lastSection {
    return [self numberOfSections] - 1;
}

- (NSIndexPath *)visibleIndexPath {
    CGRect visibleRect = (CGRect){.origin = self.contentOffset, .size = self.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    return [self indexPathForItemAtPoint:visiblePoint];
}

@end
