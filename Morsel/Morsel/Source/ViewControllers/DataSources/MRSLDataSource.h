//
//  MRSLDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

// Based off of: http://www.objc.io/issue-1/lighter-view-controllers.html
typedef void (^MRSLCellConfigureBlock)(id cell, id item, NSIndexPath *indexPath, NSUInteger count);

@interface MRSLDataSource : NSObject <UICollectionViewDataSource>

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)count;

@end
