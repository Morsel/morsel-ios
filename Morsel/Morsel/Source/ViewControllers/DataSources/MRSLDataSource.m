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

- (void)updateObjects:(id)newObjects {
    self.objects = newObjects;
}

@end
