//
//  UICollectionView+States.m
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UICollectionView+States.h"

@interface UIView (States_Private)

- (BOOL)shouldShowEmptyState;

@end

@implementation UICollectionView (States)

#pragma mark - Private Methods

- (BOOL)shouldShowEmptyState {
    if ([self.dataSource respondsToSelector:@selector(isEmpty)])
        return [(id)self.dataSource isEmpty];
    else {
        return [self numberOfItemsInAllSections] == 0;
    }
}

@end
