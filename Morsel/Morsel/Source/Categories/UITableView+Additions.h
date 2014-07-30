//
//  UITableView+Additions.h
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Additions)

- (NSInteger)numberOfRowsInAllSections;

- (BOOL)isFirstRowInSectionForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isFirstSectionForIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isLastRowInSectionForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastSectionForIndexPath:(NSIndexPath *)indexPath;

- (BOOL)hasHeaderForSection:(NSInteger)section;

@end
