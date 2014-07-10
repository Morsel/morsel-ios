//
//  MRSLDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

// Based off of: http://www.objc.io/issue-1/lighter-view-controllers.html

@interface MRSLDataSource : NSObject

- (id)initWithObjects:(id)objects;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)count;

- (void)updateObjects:(id)newObjects;

- (BOOL)isEmpty;

@end
