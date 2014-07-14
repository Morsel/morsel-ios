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
    for(NSInteger i = 0; i < [self numberOfSections]; i++)
        rowCount += [self numberOfItemsInSection:i];
    return rowCount;
}

@end
