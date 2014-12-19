//
//  MRSLDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//
// TODO: Create a @protocol for <DataSourceable> so that 'objects' other than
//       NSArray can be used as long as they respond to methods like -count, etc.

#import "MRSLDataSource.h"

@interface MRSLDataSource ()

@property (strong, nonatomic) id objects;

@end

@implementation MRSLDataSource

- (id)initWithObjects:(id)objects {
    self = [super init];
    if (self) {
        self.objects = objects;
    }
    return self;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.objects count] == 0 || indexPath.row >= [self count]) return nil;
    return self.objects[(NSUInteger)indexPath.row];
}

- (NSUInteger)count {
    return [self.objects count];
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.objects indexOfObject:object];
}

- (void)addObject:(id)object {
    NSMutableArray *mutableArray = [self.objects mutableCopy];
    [mutableArray addObject:object];
    self.objects = [NSArray arrayWithArray:mutableArray];
}

- (void)updateObjects:(id)newObjects {
    self.objects = newObjects;
}

- (BOOL)isEmpty {
    return [self count] == 0;
}

- (BOOL)containsObject:(id)object {
    return [self.objects containsObject:object];
}

- (BOOL)removeObject:(id)object {
    NSInteger indexOfObjectToRemove = [self.objects indexOfObject:object];
    if (indexOfObjectToRemove != NSNotFound) {
        NSMutableArray *mutableArray = [self.objects mutableCopy];
        [mutableArray removeObjectAtIndex:indexOfObjectToRemove];
        self.objects = [NSArray arrayWithArray:mutableArray];
        return YES;
    }
    return NO;
}

@end
