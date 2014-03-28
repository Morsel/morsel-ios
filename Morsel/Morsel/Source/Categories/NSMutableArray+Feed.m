//
//  NSMutableArray+Feed.m
//  Morsel
//
//  Created by Javier Otero on 3/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "NSMutableArray+Feed.h"

@implementation NSMutableArray (Feed)

+ (NSMutableArray *)feedIDArray {
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[NSMutableArray feedIDPath]] ?: [NSMutableArray array];
    return array;
}

+ (NSString *)feedIDPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:[@"Documents/" stringByAppendingString:@"temp.plist"]];
}

+ (void)resetFeedIDArray {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSMutableArray feedIDPath]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSMutableArray feedIDPath]
                                                   error:nil];
    }
}

- (void)saveFeedIDArray {
    NSArray *arrayToSave = [(NSMutableArray *)self subarrayWithRange:NSMakeRange(0, fmin(3, [(NSMutableArray *)self count]))];
    [arrayToSave writeToFile:[NSMutableArray feedIDPath]
                  atomically:YES];
}

@end
