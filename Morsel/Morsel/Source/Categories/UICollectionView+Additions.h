//
//  UICollectionView+Additions.h
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Additions)

- (NSInteger)numberOfItemsInAllSections;

- (BOOL)isFirstItemInSectionForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isFirstSectionForIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isLastItemInSectionForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastSectionForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastItemForIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)lastSection;

- (NSIndexPath *)visibleIndexPath;

@end
